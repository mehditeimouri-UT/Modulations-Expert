% This function performs DPSK demodulation on a complex baseband signal.
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
%   y: Complex baseband signal as a row vector with length greater than or
%       equal to (L+1)*Mod.sps and less than (L+2)*Mod.sps
%
% Output:
%   data: 1x(log2(Mod.M)*L) binary (0 and 1) demodulated information.
%   s_hat: Optimally sampled output signal of demodulator
%
% References:
%   [1] M. K. Simon and M.-S. Alouini, Digital communication over fading channels: John Wiley & Sons, 2000 (Chapter 3).
%
% Revisions:
% 2020-Sep-03   function was created

function [data,s_hat] = dpskdemod_ME(Mod, y)

%% Get Modulation Parameters
symbolmap = Mod.Rxsymbolmap;
sps = Mod.sps;
M = Mod.M;
phaserot = Mod.phaserot;
h = Mod.PulseShaping.h;
dfcTs = Mod.dfcTs;
delay = Mod.PulseShaping.delay;
half_symbol = Mod.PulseShaping.half_symbol;

%% Signal Constellation
ModSymbols = exp(1i*(2*pi*(0:M-1)/M)'+1i*phaserot); % Constellation points

%% Cancel frequency and phase offset
y = exp(-1i*2*pi*dfcTs*(0:length(y)-1)/sps).*y;

%% Matched Filter
y = conv(y,h);
y = y(1+delay:end-delay);

%% Differential Demodulation
s_hat = conj(y(half_symbol+1:sps:end-sps)).*y(sps+half_symbol+1:sps:end); 

L = floor(length(y)/sps)-1;
s_hat = s_hat(1:L);

%% Hard Decision
[~,symbols] = min(abs(repmat(s_hat,M,1)-repmat(ModSymbols,1,numel(s_hat))));
symbols = symbolmap(symbols);
data = reshape(de2bi(symbols,log2(M),'left-msb')',1,[]);