% This function implements AWGN channel.
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
%   s: noiseless modulated signal
%   SNR: signal to noise ratio (dB)
%   IgnoreNoSignalTimes: if true, the power of the signal is calculated over non-zero samples
%   UnitPower: if true, output noisy and noiseless signals are normalized to have unit average power
%
% Outputs:
%   y: noisy modulated signal with unit average power and signal to noise ratio SNR
%
% Revisions:
% 2020-Sep-14   function was created

function y = AWGN_ME(s,SNR,IgnoreNoSignalTimes,UnitPower)

%% Add noise
if IgnoreNoSignalTimes
    Ps = mean(abs(s(s~=0)).^2); % Signal power
else
    Ps = mean(abs(s).^2); % Signal power
end
Pn = Ps/(10.^(SNR/10)); % Noise power

if isreal(s)
    y = s+sqrt(Pn)*randn(size(s)); % Add noise
else
    y = complex(s+sqrt(Pn/2)*(randn(size(s))+1i*randn(size(s)))); % Add noise
end

%% Normailze Signals
if UnitPower
    Py = mean(abs(y).^2);
    y = y/sqrt(Py); % Normalize output signal
    s = s/sqrt(Ps); % Normalize output signal
end