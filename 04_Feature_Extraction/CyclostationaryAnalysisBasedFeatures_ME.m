% This function extracts Cyclostationary Analysis-based Features of a complex signal x based on the following reference:
%
%   [1] B. Ramkumar, "Automatic modulation classification for cognitive radios using cyclic feature detection," 
%       IEEE Circuits and Systems Magazine, vol. 9, pp. 27-45, 2009.
%
%   Note: The paper normalizes SCF to obtain SC. However, according to our
%   observations, this normalization results in bad results for high SNR
%   values. So, we employ a diffrent normalization. 
%
% Copyright (C) 2021 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
%   Nfft: Number of FFT points
%   L: Length of moving average filter
%
% Output:
%   F: 1xceil(Nfft/2) feature vector composed of the CF values. 
%
% Revisions:
% 2021-Jan-02   function was created

function F = CyclostationaryAnalysisBasedFeatures_ME(x,Nfft,L)

%% Step 1: Divide the signal into N frames
xN = vec2mat(x,Nfft);
N = size(xN,1);
if N>1 && mod(length(x),Nfft)~=0
    xN = xN(1:end-1,:);
end

%% Step 2: Take the Fourier transform of each frame
X = fft(xN.').';
F = 0:Nfft-1;

%% Step 6: Repeat the operation to obtain SCF
Alpha = (0:2:Nfft-1);
S = zeros(length(Alpha),Nfft);
cnt = 0;
for alpha = Alpha
    
    %% Step 3: Shift the FFT of each frame by alpha/2 and -alpha/2 and multiply them
    F1 = mod(F+alpha/2,Nfft);
    F2 = mod(F-alpha/2,Nfft);
    SN = (X(:,F1+1).*conj(X(:,F2+1)))/Nfft;
    
    %% Step 4: Take the average value of all the N frames
    cnt = cnt+1;
    S(cnt,:) = mean(SN,1);
    
end

%% Step 5: Perform frequency smoothening
S = fftshift(filter(1/L*ones(1,L),1,fftshift(S.',1)).',2);
F = max(abs(S),[],2).';

%% Step 7: Normalize the SCF
Norm_Factor = max(max(F));
if Norm_Factor~=0
    F = F/Norm_Factor;
end