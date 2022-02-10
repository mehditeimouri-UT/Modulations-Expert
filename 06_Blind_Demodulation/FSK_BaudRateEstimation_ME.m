% This function estimates baud rate of a complex signal with fsk modulations.
% It is assumed that signal x is down-converted to baseband and it probably contains a
% small frequency offset.
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
%   References:
%   [1]  A. W. Wegener, "Practical techniques for baud rate estimation," 
%       in Acoustics, Speech, and Signal Processing, 1992. ICASSP-92., 1992 IEEE International Conference on, 1992, pp. 681-684.
%
% Inputs:
%   y: Complex baseband recieved signal
%   fs: Sampling frequency (Hz)
%   Nfft: Number of FFT points
%   D: Overlap in analysis windows
%   M: Modulation order
%
% Outputs:
%   Rs_hat: Baud rate (Hz)
%
% Revisions:
% 2020-Dec-13   function was created

function Rs_hat = FSK_BaudRateEstimation_ME(y,fs,Nfft,D,M)

%% Bandwidth Estimation and initial guess for symbol timing 
[~,~,fl,fu] = BandwidthEstimation_ME(y,fs,Nfft,D);
BW_est = max(abs(fl),abs(fu));
Rs_init = 2*BW_est/(M+1);
T_init = fs/Rs_init;

%% Instantaneous Frequency 
phi_NL = angle(y);
fN = 1/(2*pi)*diff(unwrap(phi_NL));
fm = fN-mean(fN);
fm = filter(ones(1,min(3,round(T_init/2))),1,fm); % smoothing frequency in order to smooth glitches

%% Find frequency Transitions
fm = fm>0;
dfm = diff(fm);
Ts = diff(find(dfm~=0));
T_ave = mode(Ts); % Initial guess
if T_ave<=1
    T_ave = T_init;
end
bauds = round(Ts/T_ave);
T_hat = mean(Ts/bauds);
Rs_hat = fs/T_hat;