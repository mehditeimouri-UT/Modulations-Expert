% This function performs modulation for independent-sideband (ISB) modulation on a complex baseband signal.
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
%   x: 2xL sampled analog input data.
%
% Output:
%   y: Complex baseband signal as a row vector with length L
%
% Revisions:
% 2020-Sep-06   function was created

function y = isbmod_ME(Mod, x)

%% Get Modulation Parameters
ini_phase = Mod.ini_phase;
dfc_div_fs = Mod.dfc_div_fs;
sps = Mod.sps;

%% Resampling
x = interp1((0:length(x)-1),x',(0:1/sps:length(x)-1),'linear')';

%% Split channels and normalize them
x1 = x(1,:);
x1 = x1/max(abs(x1)); 
x2 = x(2,:);
x2 = x2/max(abs(x2)); 

%% Remove positive frequencies for obtaining LSB
X1 = fft(x1); 
F = (0:length(x1)-1)/length(x1); 

X1(F<0.5 & F>0) = 0; 
X1(F>0.5) = 2*X1(F>0.5); 

%% Remove nagative frequencies for obtaining USB
X2 = fft(x2); 

X2(F>0.5) = 0; 
X2(F<0.5 & F>0) = 2*X2(F<0.5 & F>0); 

%% Add LSB and USB
x_isb = ifft(X1+X2);

%% Modulation and applying frequency and phase offset
n = (0:numel(x_isb)-1);
y = complex(x_isb.*exp(1i*2*pi*dfc_div_fs*n+1i*ini_phase));