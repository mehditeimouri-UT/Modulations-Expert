% This function extracts amplitudes histogram features for a complex signal x based on the following reference:
%
%   [1] T. A. Almohamad, M. F. M. Salleh, M. N. Mahmud, and A. H. Y. Sa’D, 
%       "Simultaneous determination of modulation types and signal-to-noise ratios using feature-based approach," 
%       IEEE access, vol. 6, pp. 9262-9271, 2018.
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
%   M: Number of bins in histogram calculation
%
% Output:
%   F: 1xM feature vector of normalized histogram
%
% Revisions:
% 2021-Jan-03   function was created

function F = AmplitudeHistograms_ME(x,M)

Norm_Factor = max(abs(x));
if Norm_Factor>0
    x = x/Norm_Factor; % Normalization
end

[F,~] = histcounts(abs(x),(0:1/M:1));
F = F/sum(F)*M;