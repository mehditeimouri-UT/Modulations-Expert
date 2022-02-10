% This function extracts High-order Moment-based Features of a complex signal x based on the eq. (5.40) of the following reference:
%
%   [1] A. K. Nandi and Z. Zhu, Automatic Modulation Classification: Principles, Algorithms and Applications: John Wiley & Sons, 2015.
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
%   Nfft: Number of FFT points in preprocessing steps
%
% Output:
%   F: Scalar feature mu(m,n)=abs(E(x^(m-n)*conj(x^n)))
%
% Revisions:
% 2021-Jan-02   function was created

function F = HighOrderSignalMoments_ME(x,m,n)

Px = mean(abs(x).^2);
if Px>0
    x = x/sqrt(Px); % Unit Power
end

F = abs(mean(x.^(m-n).*conj(x.^n)));