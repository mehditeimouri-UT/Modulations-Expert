% This function performs modulation for phase modulation (PM) modulation on a complex baseband signal.
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
%   y: Complex baseband signal as a row vector with length floor(L*Mod.sps)
%
% Revisions:
% 2020-Sep-09   function was created

function y = pmmod_ME(Mod, x)

%% Get Modulation Parameters
h = Mod.h;
sps = Mod.sps;
ini_phase = Mod.ini_phase;
dfc_div_fs = Mod.dfc_div_fs;

%% Resampling
x = interp1((0:length(x)-1),x,(0:1/sps:length(x)-1),'linear');

%% Differential Operator
x = diff(x);

%% Normalize x
x = x/max(abs(x)); 

%% Modulation
n = (0:numel(x)-1);
Df_div_fs = h/(2*sps);
y = exp(1i*2*pi*dfc_div_fs*n+1i*2*pi*Df_div_fs*cumsum(x)+1i*ini_phase);
