% This function re-estimates the baud-rate of fsk based on timing error in
% demodulator. The method is based on finding the best line fitted to cumulative timing error. 
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
%   TimingError: Vector which contains the symbol timing error between successive symbols
%   Rs_hat_coarse: Coarse baud-rate (Hz) based on which TimingError is obtained.
%
% Outputs:
%   Rs_hat_fine: Fine baud-rate estimation (Hz)
%
% Revisions:
% 2020-Dec-13   function was created

function Rs_hat_fine = FSK_FineBaudRateEstimation_ME(TimingError,Rs_hat_coarse)

%% Zero-mean variables
Y = cumsum(TimingError);
X = 1:length(TimingError);
Y = Y-mean(Y);
X = X-mean(X);

%% Baud-rate deviation estimation
dT = sum(Y.*X)/sum(X.*X);

%% Fine baud-rate estimation
Rs_hat_fine = Rs_hat_coarse-dT;