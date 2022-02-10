% This function performs GMSK demodulation on a complex baseband signal.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
% 
% This file is a part of Modulations-Expert software, a software package for
% feature extraction from modulated signals and classification among various modulations.
% 
% Modulations-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License 
% as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% Modulations-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <http://www.gnu.org/licenses/>.
%
% Inputs:
%   Mod: Modulation structure
%           Note: For definition, see Initialize_Modulation_ME function.
%   y: Complex baseband signal as a row vector with length
%      greater than or equal to (N+Mod.L)*Mod.sps and less than (N+1+Mod.L)*Mod.sps
%           Note: It is assumed that Mod.L/2 zero data symbols are placed at each of the the begining and the
%           end of data before modulation. So, Finally, Mod.L demodulated symbols are
%           removed. 
%   show_progress: If true, a progress bar is shown during the demodulation
%       process. 
%
% Output:
%   data: 1xN binary (0 and 1) demodulated information.
%
% References:
%   [1] J. G. Proakis and M. Salehi, "Digital Communications, McGraw-Hill," Inc., New York, 1995 (Chapter 5).
%
% Revisions:
% 2020-Sep-01   function was created

function data = gmskdemod_ME(Mod, y, show_progress)

%% Get Modulation Parameters
sps = Mod.sps; % Number of samples per symbol
L = Mod.L; % Pulse length (in symbol duration)
ini_phase = Mod.ini_phase; % Initial phase of modulator
dfcTs = Mod.dfcTs; % Product of frequency deviation of modulator and symbol duration

%% Cancel frequency and phase offset
y = exp(-1i*2*pi*dfcTs*(0:length(y)-1)/sps).*y;
y = exp(-1i*ini_phase).*y;
N0 = floor(length(y)/sps); % N0 = N+L, where N is the length of data vector at the modulator input

%% Prepare phase filter 
alpha = Mod.PulseShaping.alpha;

%% Define States
% state is defined as [I_(0) bit_(-(L/2-1)) ... bit_(-1) bit_(0) bit_(1) ... bit_((L/2-1))]
%   bit_(0) is the current bit
%   theta_(0) = I_(0)*pi/2 is the current phase 

states = [reshape(repmat(0:3,2^(L-1),1),[],1) repmat(de2bi((0:2^(L-1)-1),L-1),4,1)];
S = 4*2^(L-1); % Number of states

%% Find Reverse State Diagram
Prev_States = zeros(S,2);
Prev_Inputs = zeros(S,2);
for j=1:S
    s_c = states(j,:); % Current State
    I_c = s_c(1); % Current Phase
    bits_c = s_c(2:end); % Current Bits
    for b = 0:1 % bit_(ptr+(L/2))
        I_n = mod(I_c+(2*bits_c(1)-1),4);
        bits_n = [bits_c(2:end) b];
        s_n = [I_n bits_n];
        
        s = find(all(repmat(s_n,S,1)==states,2));        
        i = find(Prev_States(s,:)==0,1,'first');
        Prev_States(s,i) = j;
        Prev_Inputs(s,i) = b;        
    end
end

%% Viterbi Algorithm for Demodulation
ptr = 0; % Data pointer
Decision_States = zeros(S,N0);
Decison_Inputs = zeros(S,N0);
metrics = zeros(S,1);

if show_progress
    progressbar_ME('GMSK Demodulation ...');
end

for j = 1:N0 % Loop over symbols
    
    next_metrics = inf*ones(S,1);
    
    for s = 1:S % Loop over states
        
        met = inf;
        
        for i=1:2 % loop over inputs
            
            curr_state = states(Prev_States(s,i),:);
            curr_input = Prev_Inputs(s,i);
            path = exp(1i*pi/2*(curr_state(1)+sum(repmat(2*[curr_state(2:end) curr_input]'-1,1,sps).*alpha,1)));  
            met_tmp = metrics(Prev_States(s,i))+sum(abs(y(ptr+(1:sps))-path).^2);
            
            if met_tmp<met % check of the path is survivor
              next_metrics(s) = met_tmp;  
              met = met_tmp;
              Decison_Inputs(s,j) = curr_input;
              Decision_States(s,j) = Prev_States(s,i);
            end            
            
        end
    end
    
    % Progress
    if show_progress
        stopbar = progressbar_ME(1,j/N0);
        if stopbar
            data = [];
            return;
        end
    end
    
    metrics = next_metrics;
    ptr = ptr+sps;
    
end

%% Make Decisions about Data Symbols
data = zeros(1,N0);

[~,s] = min(metrics);
for j=N0:-1:1
    
    data(j) = Decison_Inputs(s,j);
    s = Decision_States(s,j);
    
end

data = data(1:end-L); % Remove dummy symbols