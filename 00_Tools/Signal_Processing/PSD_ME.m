% This function calculates power spectral density of input signal.
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
% For real signals, PSD_ME returns the one-sided PSD by default; for complex signals,
%   it returns the two-sided PSD.  
%       Note: A one-sided PSD contains the total power of the input signal.
%
% Inputs:
%   y: input signal (a row vector)
%   fs: Sampling frequency of y
%   Nfft: Window size
%   D: overlap (<Nfft)
%
% Outputs:
%   p: psd of signal y (Watts/Hz)
%   f: frequencies (Hz) at which psd is calculated
%   LRBalance: Total power of positive frequencies minues total power negative frequencies (normalized by total power)
%               When input is real, the value of zero is returned for this parameter.%
% Revisions:
% 2020-Sep-06   function was created

function [p,f,LRBalance] = PSD_ME(y,fs,Nfft,D)

%% Error Checking
if size(y,1)>1
    error('Input signal should be a row vector.')
end

if length(y)<Nfft
    error('Length of data should not be less than nfft.')
end

if D>=Nfft
    error('Overlap D should be less than nfft.')
end

%% Calculate PSD
L = length(y);
skip = Nfft-D;
pos = 1;
cnt = 0;
p = zeros(1,Nfft); % initialize periodogram
while (pos+Nfft-1)<=L % Windowing with overlap
    Y = fft(y(pos:pos+Nfft-1));
    p = p+1/Nfft^2*abs(Y).^2; % update periodogram
    pos = pos+skip;
    cnt = cnt+1;
end
p = p/cnt;
f = (0:Nfft-1)/Nfft*fs;
M = floor(Nfft/2);

%% One-Sided | Two-Sided
if isreal(y)
    p0 = p(1);
    p1 = p(2:end-M);
    p2 = fliplr(p(end-M+1:end));
    if length(p1)<length(p2)
        p1 = [p1 0];
    end
    p = [p0 p1+p2];
    f = f(1:length(p));
    LRBalance = 0;
else
    % Calculate L-R Balance
    LP = sum(p(end-M+1:end));
    RP = sum(p(2:end-M));
    LRBalance = (RP-LP)/(RP+LP+p(1));
    
    p = [p(end-M+1:end) p(1:end-M)];
    f = [f(end-M+1:end)-fs f(1:end-M)];
end
p = p./(fs/Nfft); % Normalize