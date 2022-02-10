% This function estimates baud rate and tone frequencies of a complex signal with fsk modulations.
% It is assumed that signal x is down-converted to baseband and it probably contains a
% small frequency offset. 
%
%   Note: It is assumed that the baud rate is equal to frequency seperation.
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
%   r: Complex baseband recieved signal
%   fs: Sampling frequency (Hz)
%   Nfft: Number of FFT points
%   D: Overlap in analysis windows
%   M: Modulation order
%
% Outputs:
%   Rs_hat: Baud rate (Hz)
%   freqs: 1xM list of tone frequencies (Hz)
%
% Revisions:
% 2020-Dec-13   function was created

function [Rs_hat,freqs] = FSK_BaudRateFreqsEstimation_ME(r,fs,Nfft,D,M)

%% Power spectral density
Thr = 6; % Initial Level below the maximum level which is acceptable as tone activity
[p,f] = PSD_ME(r,fs,Nfft,D);

%% Search for peaks
P = 10*log10(p);
Pmax = max(P);
Pmin = min(P);
P(P<(Pmax-Thr)) = Pmin;
freqs = zeros(1,M);
cnt = 0;
for i=2:length(P)-1
    if P(i)>P(i-1) && P(i)>P(i+1)
        cnt = cnt+1;
        if cnt<=M
            freqs(cnt) = sum(p(i+(-1:1)).*f(i+(-1:1)))/sum(p(i+(-1:1)));
        else
            Rs_hat = [];
            freqs = [];
            return;
        end
    end
end

if cnt<M % Number of peaks is less than M
    Rs_hat = [];
    freqs = [];
    return;
end

%% Baud-rate estimation
Rs_hat = mean(diff(freqs));
