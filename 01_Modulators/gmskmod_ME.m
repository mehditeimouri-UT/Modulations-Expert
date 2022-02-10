% This function performs GMSK modulation on a binary vector.
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
%   data: 1xN binary (0 and 1) input vector.
%
% Output:
%   y: Complex baseband signal as a row vector with length (N+Mod.L)*Mod.sps
%           Note: Mod.L/2 zero data symbols are placed at each of the the begining and the
%           end of data before modulation. 
%
% References:
%   [1] K. Murota and K. Hirade, "GMSK modulation for digital mobile radio telephony," 
%       IEEE Transactions on communications, vol. 29, pp. 1044-1050, 1981.
%
% Revisions:
% 2020-Sep-01   function was created

function y = gmskmod_ME(Mod, data)

%% Get Modulation Parameters
sps = Mod.sps; % Number of samples per symbol
L = Mod.L; % Pulse length (in symbol duration)
ini_phase = Mod.ini_phase; % Initial phase of modulator
dfcTs = Mod.dfcTs; % Product of frequency deviation of modulator and symbol duration

% Pulse shanping 
g = Mod.PulseShaping.g;
delay = Mod.PulseShaping.delay;

%% Prepare Data
% Adding L-1 dummy bits 1 at each of the the begining and the end of data before modulation.
% Adding L/2 zero data symblos at each of the the begining and the end of data before modulation.
data = [ones(1,L-1) zeros(1,L/2) data(:)' zeros(1,L/2) ones(1,L-1)];

%% Convert unipolar data to bipolar data
data = 2*data-1;

%% Calculating the phase of the modulated signal
phi = cumsum(conv(g,upsample(data,sps)));

%% Select the active part of signal (i.e. remove dummy samples)
phi = phi(1+(L-1)*sps+delay:end-delay-(L-1)*sps);

%% Set the initial phase
phi = pi/2*phi+ini_phase;

%% Apply frequency offset
phi = phi+2*pi*dfcTs*(0:length(phi)-1)/sps;

%% Generate complex baseband signal
y = complex(cos(phi),sin(phi));