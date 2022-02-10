% This function extracts signal spectral-based features of a complex signal x based on section 5.2 of the following reference:
%
%   [1] A. K. Nandi and Z. Zhu, Automatic Modulation Classification: Principles, Algorithms and Applications: John Wiley & Sons, 2015.
%
% It is assumed that signal x is down-converted to baseband and it probably contains a small frequency offset.
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
%   At: thresould for detemining low-amplitude samples (a value around 1)
%
% Output:
%   F: 1x9 feature vector composed of the following features 
%       gamma_max: maximum value of the spectral power density of the normalized and centred instantaneous amplitude of the received signal  
%       sigma_ap: standard deviation of the absolute value of the non-linear component of the instantaneous phase
%       sigma_dp: standard deviation of the non-linear component of the direct instantaneous phase
%       P: spectrum symmetry around the carrier frequency
%       sigma_aa: standard deviation of the absolute value of the normalized and centred instantaneous amplitude
%       sigma_af: standard deviation of the absolute value of the normalized and centred instantaneous frequency
%       sigma_a: standard deviation of the normalized and centred instantaneous amplitude
%       mu42_a: kurtosis of the normalized and centred instantaneous amplitude
%       mu42_f: kurtosis of the normalized and centred instantaneous frequency
%
% Revisions:
% 2020-Sep-21   function was created

function F = SpectralBasedFeatures_ME(x,At)

%% Calculating gamma_max
N = length(x);
A = abs(x);
mu_A = mean(A);
if mu_A>0
    An = A/mu_A;
else
    An = A;
end
Acn = An-1;
gamma_max = max(abs(fft(Acn)).^2)/N;

%% Calculating sigma_ap
phi_NL = angle(x);
phi_NL = phi_NL-mean(phi_NL); % remove unknown phase offset 
idxA = An>At;
Nc = sum(idxA);
phi_NL_d = phi_NL(idxA);
phi_NL_a = abs(phi_NL_d);
sigma_ap = sqrt(1/Nc*sum(phi_NL_a.^2)-(1/Nc*sum(phi_NL_a)).^2);

%% Calculating sigma_dp
sigma_dp = sqrt(1/Nc*sum(phi_NL_d.^2)-(1/Nc*sum(phi_NL_d)).^2);

%% Calculating P
X = abs(fft(x,N)).^2;
M = floor(N/2);
PL = sum(X(end-M+1:end));
PU = sum(X(2:end-M));
if (PL+PU)~=0
    P = (PL-PU)/(PL+PU);
else
    P = 1;
end

%% Calculating sigma_aa
sigma_aa = sqrt(1/N*sum(Acn.^2)-(1/N*sum(abs(Acn))).^2);

%% Calculating sigma_af
fN = 1/(2*pi)*diff(unwrap([0 phi_NL]));

absfN = abs(fN);

% Remove Spikes in Frequency (Modified by Mehdi Teimouri)
idx0 = absfN(2:end-1)>2*absfN(1:end-2) & absfN(2:end-1)>2*absfN(3:end);
idx1 = 2:numel(fN)-1;
idx2 = 1:numel(fN)-2;
fN(idx1(idx0)) = fN(idx2(idx0)); 

fm = fN-mean(fN);
fm_a = abs(fm(idxA));
sigma_af = sqrt(1/Nc*sum(fm_a.^2)-(1/Nc*sum(fm_a)).^2);

%% Calculating sigma_a
sigma_a = sqrt(1/Nc*sum(Acn(idxA).^2)-(1/Nc*sum(Acn(idxA))).^2);

%% Calculating mu42_a
Val = mean(Acn.^4);
Norm_Factor = mean(Acn.^2)^2;
if Norm_Factor>0
    mu42_a = Val/Norm_Factor;
else
    mu42_a = Val;
end

%% Calculating mu42_f
Val = mean(fN.^4);
Norm_Factor = mean(fN.^2)^2;
if Norm_Factor>0
    mu42_f = Val/Norm_Factor;
else
    mu42_f = Val;
end

%% Feature Vector
F = [gamma_max,sigma_ap,sigma_dp,P,sigma_aa,sigma_af,sigma_a,mu42_a,mu42_f];