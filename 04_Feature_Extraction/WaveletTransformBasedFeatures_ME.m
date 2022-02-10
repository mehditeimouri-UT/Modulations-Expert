% This function extracts wavelet transform-based features of a complex signal x based on the following reference:
%
%   [1] K. Hassan, I. Dayoub, W. Hamouda, and M. Berbineau, "Automatic modulation recognition using wavelet transform and neural networks in wireless systems," 
%       EURASIP Journal on Advances in Signal Processing, vol. 2010, pp. 1-13, 2010.
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
%   T: 1xL vector of integers with elements greater than or equal to 2 that
%       define the Haar wavelet scales. 
%   n: Maximum order of moments to be calculated (n>=2).
%
% Output:
%   Fv: 1x(k*4*length(T)) feature vector composed of the following features, respectively:
%       WT_M_1_T_i1, ..., WT_M_k_T_i1, WT_med_M_1_T_i1, ..., WT_med_M_k_T_i1, WTn_M_1_T_i1, ..., WTn_M_k_T_i1, WTn_med_M_1_T_i1, ..., WTn_med_M_k_T_i1
%       WT_M_1_T_i2, ..., WT_M_k_T_i2, WT_med_M_1_T_i2, ..., WT_med_M_k_T_i2, WTn_M_1_T_i2, ..., WTn_M_k_T_i2, WTn_med_M_1_T_i2, ..., WTn_med_M_k_T_i2
%       ...
%       , in which i=i1,i2,... gets its values from T. 
%   WT_M_j_T_i is the jth moment of wavelet transform of x with scale i
%   WT_med_M_j_T_i is the jth moment of median-filtered wavelet transform of x with scale i
%   WTn_M_j_T_i is the jth moment of wavelet transform of normalized x with scale i
%   WTn_med_M_j_T_i is the jth moment of median-filtered wavelet transform of normalized x with scale i
%
% Revisions:
% 2020-Dec-30   function was created

function Fv = WaveletTransformBasedFeatures_ME(x,T,k)

%% Normalize Signal
Px = mean(abs(x).^2);
if Px>0
    x = x/sqrt(Px); % Unit Power
end

xn = x./abs(x); % Unit Amplitude
xn(isnan(xn)) = 0;

%% Claculating waveler transform
F = zeros(k,length(T));
F_med = zeros(k,length(T));
Fn = zeros(k,length(T));
Fn_med = zeros(k,length(T));
cnt = 0;

for t = T % Different Scales
    
    cnt = cnt+1;
    
    % Haar Filter 
    h = [-ones(1,floor(t/2)) ones(1,ceil(t/2))]/sqrt(t);
    
    % Wavelet Transform of Signal
    X = conv(x,h);
    X = abs(X(t:end-t+1));
    X_med = medfilt1(X,t); % Median Filtering
    
    % Wavelet Transform of Normalized Signal
    Xn = conv(xn,h);
    Xn = abs(Xn(t:end-t+1));
    Xn_med = medfilt1(Xn,t); % Median Filtering
    
    % Calculating Features: Mean
    F(1,cnt) = mean(X);
    F_med(1,cnt) = mean(X_med);
    Fn(1,cnt) = mean(Xn);
    Fn_med(1,cnt) = mean(Xn_med);

    % Calculating Features: Variance
    F(2,cnt) = var(X);
    F_med(2,cnt) = var(X_med);
    Fn(2,cnt) = var(Xn);
    Fn_med(2,cnt) = var(Xn_med);
    
    % Calculating Features: Higher Order Moments
    for j=3:k
        F(j,cnt) = mean(X.^j);
        F_med(j,cnt) = mean(X_med.^j);
        Fn(j,cnt) = mean(Xn.^j);
        Fn_med(j,cnt) = mean(Xn_med.^j);
    end
    
end

%% Feature Vector
Fv = reshape([F ; F_med ; Fn ; Fn_med],1,[]);