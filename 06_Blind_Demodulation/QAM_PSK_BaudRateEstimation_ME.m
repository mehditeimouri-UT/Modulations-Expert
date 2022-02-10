% This function estimate baud-rate for QAM and PSK modulated data. 
% It is assumed that root raised cosine pulse shaping is used in modulator. 
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
%   y: Complex baseband recieved signal whiech may contain a frequency deviation
%   fs: Sampling frequency (Hz)
%   Nfft: Number of FFT points
%   D: Overlap in analysis windows
%
% Outputs:
%   Rs_hat: Baud rate (Hz)
%   df: Esimation of frequency deviation
%
% References:
%   [1] M. A. Elgenedy and A. Elezabi, "Blind symbol rate estimation using autocorrelation and zero crossing detection," 
%       in Communications (ICC), 2013 IEEE International Conference on, 2013, pp. 4750-4755.
%
% Revisions:
% 2020-Dec-10   function was created

function [Rs_hat,df] = QAM_PSK_BaudRateEstimation_ME(r,fs,Nfft,D)

%% Bandwidth Estimation and initial guess for symbol timing 
[~,~,fl,fu,~,~,~,~] = BandwidthEstimation_ME(r,fs,Nfft,D);
BW_est = max(abs(fl),abs(fu));
sps_est_init = fs/BW_est;
MAXLAG = round(2*sps_est_init); % Set equal to two symbols
if MAXLAG<30
    MAXLAG = 30;
end

%% Calculare Auto-Correlation
R = zeros(1,MAXLAG);
for t = 1:MAXLAG
    R(t) = sum(r(1:end-t).*conj(r(1+t:end)));
end

%% Estimation of Frequency Deviation (and Apply to Auto-Correlation)
df = -angle(R(1))/(2*pi)*fs;
R = R.*exp(1i*2*pi*df/fs*(1:length(R)));

%% Symbol Duration Estimation
idx = find(real(R)<0,1,'first');
if isempty(idx) || idx<5
    df = [];
    Rs_hat = [];
    return;
end

x = (-4:0)+idx; % Include four point before zero crossing
y = real(R(x));

% Not-A-Knot Cubic Spline Interpolation
p = CubicSplineFit_ME(x',y');
c = p(4,:);

% Estimation of Baud-Rate Using the Zero-Crossing Point
f = @(t) sum(t.^(3:-1:0).*c);
T = idx-1;
dt = fzero_ME(f,0,1,1e-6);
T = T+dt; 
Rs_hat = fs/T;

function coeffs = CubicSplineFit_ME(xi,yi)

% This function is for not-a-knot cubic spline interpolation using n>3 points.
% xi and yi are column vectors with size n>3.

%% Preprocessing
xi = xi(:);
yi = yi(:);
n = length(yi);
dx = diff(xi); 
divdif = diff(yi)./dx;

%% set up the linear system for solving for the slopes at xi
B = [[dx(2:n-1);0;0] [0;2*(dx(2:n-1)+dx(1:n-2));0] [0;0;dx(1:n-2)]];
d = [-1 0 1]';
p = length(d);
m = n;   
len = max(0, min(m, n-d) - max(1, 1-d) + 1);
len = [0; cumsum(len)];
a = zeros(len(p+1), 3);

for k = 1:p
    i = (max(1,1-d(k)):min(m,n-d(k)))';
    a((len(k)+1):len(k+1),:) = [i i+d(k) B(i+(m>=n)*d(k),k)];
end
c = zeros(m,n);
for j=1:size(a,1)
    c(a(j,1),a(j,2)) = a(j,3);
end

xi31 = xi(3)-xi(1); 
xin = xi(n)-xi(n-2);
c(1,1:2) = [dx(2) xi31];
c(n,n-1:n) = [xin dx(n-2)];
b = zeros(n,1);
b(1,:) = ((dx(1)+2*xi31)*dx(2)*divdif(1,:)+dx(1)^2*divdif(2,:))/xi31;
b(2:n-1,:) = 3*(dx(2:n-1).*divdif(1:n-2,:)+dx(1:n-2).*divdif(2:n-1,:));
b(n,:) = (dx(n-1)^2*divdif(n-2,:)+((2*xin+dx(n-1))*dx(n-2))*divdif(n-1,:))/xin;

%% solve for the slopes
s = c\b;
c4 = (s(1:n-1,:)+s(2:n,:)-2*divdif(1:n-1,:))./dx;
c3 = (divdif(1:n-1,:)-s(1:n-1,:))./dx - c4;

%% Coefficients
coeffs = reshape([(c4./dx).' c3.' s(1:n-1,:).' yi(1:n-1,:).'],(n-1),4);
