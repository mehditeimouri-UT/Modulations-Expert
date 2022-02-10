% This function performs FSK modulation on a binary vector.
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
%       Note: For definition, see Initialize_Modulation_ME function.
%   data: 1x(log2(Mod.M)*L) binary (0 and 1) input vector.
%       Note: If data length is not a multiple of log2(Mod.M), some dummy 0 bits are appended at the end of data.
%
% Output:
%   y: Complex baseband signal as a row vector with length L*Mod.sps
%
% References:
%   [1] M. K. Simon and M.-S. Alouini, Digital communication over fading channels: John Wiley & Sons, 2000 (Chapter 3).
%
% Revisions:
% 2020-Sep-02   function was created

function y = fskmod_ME(Mod, data)

%% Get Modulation Parameters
symbolmap = Mod.Txsymbolmap;
sps = Mod.sps;
h = Mod.h;
M = Mod.M;
phase_cont = Mod.phase_cont;
ini_phase = Mod.ini_phase;
dfcTs = Mod.dfcTs;

%% Cosntant parameters
% Initialize the phase increments and the oscillator phase for modulator with
% discontinuous phase.
phaseIncr = (2*pi*h/(2*sps))*(0:sps-1)'*(-(M-1):2:(M-1));

% phIncrSym is the incremental phase over one symbol, across all M tones.
phIncrSym = phaseIncr(end,:);

% phIncrSamp is the incremental phase over one sample, across all M tones.
phIncrSamp = phaseIncr(2,:);    % recall that phaseIncr(1,:) = 0

%% Symbol Mapping
x = symbolmap(bi2de(vec2mat(data,log2(M)),'left-msb')+1);
L = length(x);

%% Modulation
OscPhase = ini_phase*ones(1, M); % Initialization
Phase = zeros(sps*L, 1); % phase = sps*# of symbols x #

% Loop over symbols
prevPhase = ini_phase;
for iSym = 1:L
    
    % Get the initial phase for the current symbol
    if strcmpi(phase_cont,'cont')
        ph1 = prevPhase;
    else
        ph1 = OscPhase(x(iSym)+1);
    end
    
    % Compute the phase of the current symbol by summing the initial phase
    % with the per-symbol phase trajectory associated with the given M-ary
    % data element.
    Phase(sps*(iSym-1)+1:sps*iSym) = ph1*ones(sps,1) + phaseIncr(:,x(iSym)+1);
    
    % Update the oscillator for a modulator with discontinuous phase.
    % Calculate the phase modulo 2*pi so that the phase doesn't grow too
    % large.
    if strcmpi(phase_cont,'discont')
        OscPhase = rem(OscPhase + phIncrSym + phIncrSamp, 2*pi);
    end
    
    % If in continuous mode, the starting phase for the next symbol is the
    % ending phase of the current symbol plus the phase increment over one
    % sample.
    prevPhase = Phase(sps*iSym) + phIncrSamp(x(iSym)+1);
end

%% Apply frequency offset
y = exp(1i*Phase'+1i*2*pi*dfcTs/sps*(0:sps*L-1));