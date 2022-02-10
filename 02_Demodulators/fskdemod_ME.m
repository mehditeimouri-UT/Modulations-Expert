% This function performs FSK demodulation on a complex baseband signal.
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
%   y: Complex baseband signal as a row vector with length greater than or
%   equal to N*Mod.sps and less than (N+1)*Mod.sps
%
% Output:
%   data: 1x(log2(Mod.M)*N) binary (0 and 1) demodulated information.
%
% References:
%   [1] M. K. Simon and M.-S. Alouini, Digital communication over fading channels: John Wiley & Sons, 2000 (Chapter 3).
%
% Revisions:
% 2020-Sep-03   function was created

function data = fskdemod_ME(Mod, y)

%% Get Modulation Parameters
symbolmap = Mod.Rxsymbolmap;
sps = Mod.sps;
h = Mod.h;
M = Mod.M;
dfcTs = Mod.dfcTs;

%% Cancel frequency offset
y = exp(-1i*2*pi*dfcTs*(0:length(y)-1)/sps).*y;

%% Define Correlators
L = floor(length(y)/sps); % Number of symbols
CorrOutput = zeros(M,L);
freqs = (-(M-1)/2:(M-1)/2)*h; % Frequencies used for the demodulator.  
tones = exp(-1i*2*pi*(0:sps-1)'/sps*freqs); % Possible Tone

%% Correlators
for i=1:L
    CorrOutput(:,i) = abs(sum(repmat(y((i-1)*sps+(1:sps)).',1,M).*tones))';
end
    
%% Hard Decision
[~,symbols] = max(CorrOutput);
symbols = symbolmap(symbols);
data = reshape(de2bi(symbols,log2(M),'left-msb')',1,[]);