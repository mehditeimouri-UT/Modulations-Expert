% This function estimates bandwidth of real/complex input signal y where SNR is maximized  
% In order to estimate noise level, at least 10% of y in frequency domain should not contain any signal.
% For complex signals, two-sided PSD is considered.
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
%   y: input signal
%   fs: sample frequency of y (a row vector)
%   Nfft: window size for PSD calculation
%   D: overlap (<Nfft) for PSD calculation
%
% Outputs:
%   p: psd of signal y
%   f: frequencies (Hz) at which psd is calculates
%   fl: Lower band frequency (Hz)
%   fu: Upper band frequency (Hz)
%   N0: Noise level in p (linear scale)
%   SNR_est: estimation of SNR (dB)
%   LRBalance: Total power of positive frequencies minues total power negative frequencies (normalized by total power)
%               When input is real, the value of zero is returned for this parameter.
%   fc_hat_psd: estimation of carrier frequency fc (Hz) via PSD
%
% Revisions:
% 2020-Dec-10   function was created

function [p,f,fl,fu,N0,SNR_est,LRBalance,fc_hat_psd] = BandwidthEstimation_ME(y,fs,Nfft,D)

%% Error Checking
if size(y,1)>1
    error('Input signal should be a row vector.')
end

%% Power Spectral Density
[p,f,LRBalance] = PSD_ME(y,fs,Nfft,D);

%% Noise Level Estimation
% Search for the lowest level of spectrum
L = length(f);
W = floor(L/20); % Window size for estimation of noise level
W_OV = floor(W/2); % Overlap in searching for the portion which contains only noise
skip = W-W_OV;
pos = 1;
N0 = inf;
while (pos+W-1)<L % Windowing with overlap
    val = mean(p(pos:pos+W-1));
    if val<N0 % Update value of N0
        N0 = val;
    end
    pos = pos+skip;
end

%% Search for lower band frequency
lambda = 1; % Heuristic
[~,idxmax] = max(p); % Position of maximim power frequency  
maxval = -inf;
maxpos = -1;
for i=1:idxmax-1
    val = sum(p(i:idxmax)-(1+lambda)*N0);
    if val>maxval
        maxval = val;
        maxpos = i;
    end
end
fl = f(maxpos);

%% Search for upper band frequency
maxval = -inf;
maxpos1 = maxpos;
maxpos = -1;
for i=idxmax+1:length(p)
    val = sum(p(maxpos1:i)-(1+lambda)*N0);
    if val>maxval
        maxval = val;
        maxpos = i;
    end
end
fu = f(maxpos);

%% SNR Estimation
P1 = sum(p(maxpos1:maxpos)); % Power of signal plus power of noise in signal bandwidth
P2 = sum(p(1:maxpos1-1))+sum(p(maxpos+1:end)); % Power of of noise out of signal bandwidth
PN = P2/(maxpos1-1+length(p)-maxpos)*length(p);
PS = P1-P2/(maxpos1-1+length(p)-maxpos)*(maxpos-maxpos1+1); 
SNR_est = 10*log10(PS/PN);

% Carrier Frequency Estimation
fc_hat_psd = sum(p.*f)/sum(p);