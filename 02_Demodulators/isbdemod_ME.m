% This function performs demodulation for independent-sideband (ISB) modulation on a complex baseband signal.
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
%   y: Complex baseband signal as a row vector with L
%
% Output:
%   x: 2xL sampled analog demodulated data.
%
% Revisions:
% 2020-Sep-06   function was created

function x = isbdemod_ME(Mod, y)

%% Get Modulation Parameters
ini_phase = Mod.ini_phase;
dfc_div_fs = Mod.dfc_div_fs;
sps = Mod.sps;

%% Cancel frequency and phase offset
y = exp(-1i*2*pi*dfc_div_fs*(0:length(y)-1)).*y;
y = exp(-1i*ini_phase).*y;

%% Split LSB and USB
X = fft(y);
F = (0:length(y)-1)/length(y); 

% LSB
X1 = X;
X1(F<0.5 & F>0) = 0; 
x1 = ifft(X1);

% USB
X2 = X;
X2(F>0.5) = 0; 
x2 = ifft(X2);

%% Demodulation
x = [real(x1) ; real(x2)]; 

%% Resampling
x = interp1((0:length(x)-1),x',(0:sps:length(x)-1))';
