% This function implements fsk receiver including the synchronizer. 
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
%   References:
%   [1]  Zsolt, K., 2010, RECEIVER SYNCHRONIZATION FOR 2-FSK COMMUNICATION SYSTEMS.
%
% Inputs:
%   r: Complex baseband recieved signal
%   freqs: 1xM list of tone frequencies (Hz), where M is modulation order
%
% Outputs: 
%   s: Output symbols
%   v: Output bits
%   TimingError: Vector with size equal to size(s) which contains the symbol timing error between successive symbols
%
% Revisions:
% 2020-Dec-13   function was created

function [s,v,TimingError] = FSK_Receiver_ME(r,freqs)

%% Global Parameters
global RxPrms

%% Demodulator parameters
sps = RxPrms.sps;
T08 = round(0.8*RxPrms.sps);
T02 = sps-T08;
T2 = RxPrms.T2;
MaxWaitforSynch = 10; % Maximum successive transitions which are not consireded for synchronization

%% Correlators
H = zeros(RxPrms.M,round(RxPrms.sps)); % Receiver Correlators Coefficients
for j=1:RxPrms.M
    H(j,:) = exp(-1i*2*pi*freqs(j)/RxPrms.fs*(0:round(RxPrms.sps)-1));
end

r_H = zeros(RxPrms.M,length(r)-round(RxPrms.sps)+1); % Correlators outputs
for j=1:RxPrms.M
    r_tmp = conv(r,fliplr(H(j,:)));
    r_H(j,:) = abs(r_tmp(round(RxPrms.sps):length(r)));
end

%% Demapping correlator outputs
r_H_demapped = demapper_ME(r_H);
r_H_transitions = [0 diff(r_H_demapped)~=0];
s = zeros(1,round(length(r_H_demapped)*1.1));

%% Symbol Synchronization and Demodulation
r_idx = 0;
s_idx = 0;
first_transition = false;
PrevDecisionIdx = -1;
WaitforSynch = 0;
TimingError = zeros(size(s));
while (r_idx<length(r_H_demapped))
    
    % Increrement index of recieved sample 
    r_idx = r_idx+1;
        
    % Search for the first transition
    if ~first_transition
        if (r_idx+T08)>length(r_H_demapped) || (r_idx-T08+1)<1, continue; end
        if r_H_transitions(r_idx)==1 && all(r_H_transitions(r_idx-(1:T08-1))==0) && all(r_H_transitions(r_idx+(1:T08))==0)
            first_transition = true;
            counter = T2;
        end
        continue;
    end
    
    % Increrement modulo-sps index of recieved sample 
    counter = counter+1;
    
    % Make a decision if necessary
    if abs(counter-sps)<0.5

        s_idx = s_idx+1;
        s(s_idx) = r_H_demapped(r_idx);
        counter = counter-sps;
        
        if PrevDecisionIdx>0
            TimingError(s_idx) = sps-(r_idx-PrevDecisionIdx);
        end
        PrevDecisionIdx = r_idx;
    end
    
    % Synchronization
    if (r_idx+T08)>length(r_H_demapped), continue; end
    if r_H_transitions(r_idx)==1 && all(r_H_transitions(r_idx-(1:T08-1))==0) && all(r_H_transitions(r_idx+(1:T08))==0) % Transition
        
        if abs(counter-T2)<=T02
            
            counter = T2;
            WaitforSynch = 0;
            continue;
        end
        
        WaitforSynch = WaitforSynch+1;
        if WaitforSynch>MaxWaitforSynch
            counter = T2;
            WaitforSynch = 0;
        end
        
    end
    
end

%% Outputs
s(s_idx+1:end) = [];
if isempty(s)
    v = [];
else
    v = reshape(de2bi(s,log2(RxPrms.M),'left-msb')',1,[]);
end
TimingError(s_idx+1:end) = [];