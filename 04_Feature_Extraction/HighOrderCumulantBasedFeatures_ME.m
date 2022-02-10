% This function extracts High-order Cumulant-based Features of a complex signal x based on the following reference:
%
%   [1] A. Swami and B. M. Sadler, "Hierarchical digital modulation classification using cumulants," 
%       IEEE Transactions on communications, vol. 48, pp. 416-429, 2000.
%
% It is assumed that signal x is down-converted to baseband and it probably
% contains a small frequency offset. The method of Swami and Sadler assume
% that we are operating in a coherent, synchronous environment with single-tone
% signaling and that carrier, timing, and waveform recovery have been
% accomplished. So, we have added some pre-processing steps to their method in
% order to estimate constellation symbols.
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
%   x: row vector of complex signal x[n]=xr[n]+1i*xi[n]
%   Nfft: Number of FFT points in preprocessing steps
%
% Output:
%   F: 1x8 feature vector composed of the following features:
%       F = [abs(C20) abs(C40) abs(C41) abs(C42) angle(C20) angle(C40) angle(C41) angle(C42)]
%
% Revisions:
% 2020-Dec-31   function was created

function F = HighOrderCumulantBasedFeatures_ME(x,Nfft)

%% Pre-Processing Step 1: Baud-Rate and Frequency Offset Estimation
Nfft = min(Nfft,length(x));
fs = 1; % Normalized Frequency 
[BR,df] = QAM_PSK_BaudRateEstimation_ME(x,fs,Nfft,ceil(Nfft/2));
if isempty(df)
    F = -10*ones(1,8);
    return;
end

%% Pre-Processing Step 2: Design Pulse Shaping Filter
sps = fs/BR;
if sps<0.5 || length(x)<10*sps
    F = 10*ones(1,8);
    return;
end
h = rcosdesign_fr_ME(1,6,sps,'sqrt'); % pulse shaping filter
D = (length(h)-1)/2;

%% Pre-Processing Step 3: Frequency offset Compensation
Px = mean(abs(x).^2);
if Px>0
    r = x/sqrt(Px); % Normalize signal
else
    r = x;
end
r = r.*exp(-1i*2*pi*df/fs*(1:length(r))); % Frequency offset compensation

%% Pre-Processing Step 4: Matched Filtering and Optimum Sampling
r = conv(r,h);
r = r(1+D:end-D);
max_E = 0;
for i=1:sps
    rs_tmp = r(round(i:sps:length(r)));
    E = mean(abs(rs_tmp).^2);
    if E>max_E
        r_s = rs_tmp;
        max_E = E;
    end
end

%% Calculating High-order Cumulant-based Features
C21 = mean(abs(r_s).^2);
if C21~=0
    Norm_Factor = C21;
else
    Norm_Factor = 1;
end
C20 = mean(r_s.^2)/Norm_Factor;
C40 = Cumulant_ME(r_s,r_s,r_s,r_s)/Norm_Factor^2;
C41 = Cumulant_ME(r_s,r_s,r_s,conj(r_s))/Norm_Factor^2;
C42 = Cumulant_ME(r_s,r_s,conj(r_s),conj(r_s))/Norm_Factor^2;
F = [abs(C20) abs(C40) abs(C41) abs(C42) angle(C20) angle(C40) angle(C41) angle(C42)];

function C = Cumulant_ME(w,x,y,z)

C = mean(w.*x.*y.*z)-mean(w.*x)*mean(y.*z)-mean(w.*y)*mean(x.*z)-mean(w.*z)*mean(x.*y);