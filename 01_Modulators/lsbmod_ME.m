% This function performs modulation for lower-sideband (LSB) modulation on a complex baseband signal.
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
%   x: 1xL sampled analog input data.
%
% Output:
%   y: Complex baseband signal as a row vector with length L
%
% Revisions:
% 2020-Sep-06   function was created

function y = lsbmod_ME(Mod, x)

%% Get Modulation Parameters
ini_phase = Mod.ini_phase;
dfc_div_fs = Mod.dfc_div_fs;
sps = Mod.sps;

%% Resampling
x = interp1((0:length(x)-1),x,(0:1/sps:length(x)-1),'linear');

%% Normalize x
x = x/max(abs(x)); 

%% Remove positive frequencies
X = fft(x); 
F = (0:length(x)-1)/length(x); 

X(F<0.5 & F>0) = 0; 
X(F>0.5) = 2*X(F>0.5); 

x_lsb = ifft(X);

%% Modulation and applying frequency and phase offset
n = (0:numel(x_lsb)-1);
y = complex(x_lsb.*exp(1i*2*pi*dfc_div_fs*n+1i*ini_phase));