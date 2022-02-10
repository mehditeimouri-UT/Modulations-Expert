% This function performs MSK modulation on a binary vector.
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
%   data: 1x(2*N) binary (0 and 1) input vector.
%       Note: If data length is odd, one dummy 0 bit is appended at the end of data.
%
% Output:
%   y: Complex baseband signal as a row vector with length (2*N+1)*Mod.sps
%
% References:
%   [1] S. Pasupathy, "Minimum shift keying: A spectrally efficient modulation," 
%       IEEE Communications Magazine, vol. 17, pp. 14-22, 1979.
%
% Revisions:
% 2020-Sep-02   function was created

function y = mskmod_ME(Mod, data)

%% Get Modulation Parameters
sps = Mod.sps; % Number of samples per symbol
ini_phase = Mod.ini_phase; % Initial phase of modulator
dfcTs = Mod.dfcTs; % Product of frequency deviation of modulator and symbol duration

%% Append one dummy 0 bit at added at the end of data if data length is odd
data = vec2mat(data,2)'; 

%% Convert unipolar data to bipolar data
data = 2*data-1;
N = size(data,2);

%% I/Q data streams
a_I = data(1,:);
a_Q = data(2,:);

%% I/Q signals
I = reshape(repmat(a_I,2*sps,1),1,[]).*...
    cos(pi*(0:sps*2*N-1)/(2*sps)-pi/2);
Q = reshape(repmat(a_Q,2*sps,1),1,[]).*...
    sin(pi*(0:sps*2*N-1)/(2*sps));

%% Generate complex baseband signal
y = complex([I zeros(1,sps)],[zeros(1,sps) Q]);

%% Apply frequency and phase offset
y = complex(exp(1i*(ini_phase+2*pi*dfcTs*(0:length(y)-1)/sps)).*y);