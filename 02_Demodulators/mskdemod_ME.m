% This function performs MSK demodulation on a complex baseband signal.
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
%   equal to (2*N+1)*Mod.sps and less than (2*(N+1)+1)*Mod.sps
%
% Output:
%   data: 1x(2*N) binary (0 and 1) demodulated information.
%
% References:
%   [1] J. G. Proakis and M. Salehi, "Digital Communications, McGraw-Hill," Inc., New York, 1995 (Chapter 5).
%
% Revisions:
% 2020-Sep-02   function was created

function data = mskdemod_ME(Mod, y)

%% Get Modulation Parameters
sps = Mod.sps; % Number of samples per symbol
ini_phase = Mod.ini_phase; % Initial phase of modulator
dfcTs = Mod.dfcTs; % Product of frequency deviation of modulator and symbol duration

%% Cancel frequency and phase offset
y = exp(-1i*2*pi*dfcTs*(0:length(y)-1)/sps).*y;
y = exp(-1i*ini_phase).*y;

%% I/Q Correlators
N = floor((length(y)-sps)/(2*sps));
L = (2*N)*sps;
y = y(1:L+sps);
d1 = sum(reshape(cos(pi*(0:L-1)/(2*sps)-pi/2).*real(y(1:end-sps)),2*sps,[]),1);
d2 = sum(reshape(sin(pi*(0:L-1)/(2*sps)).*imag(y(1+sps:end)),2*sps,[]),1);

%% Decision Making
data = reshape([d1>=0 ; d2>=0],1,[]);