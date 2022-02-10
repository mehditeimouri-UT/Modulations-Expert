% This function performs QAM modulation on a binary vector.
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
% 2020-Sep-03   function was created

function y = qammod_ME(Mod, data)

%% Get Modulation Parameters
symbolmap = Mod.Txsymbolmap;
sps = Mod.sps;
M = Mod.M;
phaserot = Mod.phaserot;
h = Mod.PulseShaping.h;
ini_phase = Mod.ini_phase;
dfcTs = Mod.dfcTs;
delay = Mod.PulseShaping.delay;
half_symbol = Mod.PulseShaping.half_symbol;

%% Signal Constellation
Constellation = qam_constellation_ME(M).*exp(1i*phaserot);

%% Symbol Mapping
v = symbolmap(bi2de(vec2mat(data,log2(M)),'left-msb')+1);

%% Modulation
S = Constellation(v+1); % modulator output signal
x = conv(upsample(S,sps),h); % upsampling and pulse shaping
x = x(delay+1-half_symbol:end-delay-half_symbol); % remove redundant samples

%% Apply frequency and phase offset
y = complex(x.*exp(1i*2*pi*dfcTs/sps*(0:numel(x)-1)+1i*ini_phase)); 