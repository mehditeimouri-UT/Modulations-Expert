function [ConfusionMatrix,Pc] = ConfusionMatrix_ME(TrueLabels,PredictedLabels,TrueClassLabels,PredictedClassLabels,Weights)

% This function takes predictions of a decision machine and compare it with
% the true labels. The output is confusion matrix and accuracy.
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
%   TrueLabels: An Lx1 vector that contains true labels; The values are from set B0 = {1,2,...,M0}.
%   PredictedLabels: An Lx1 vector that contains the predicted labels; The values are from set B = {1,2,...,M}.
%   TrueClassLabels: 1xM0 cell that contains string labels corresponding to values B0 = {1,2,...,M0}
%   PredictedClassLabels: 1xM cell that contains string labels corresponding to values B = {1,2,...,M}
%   Weights: Lx1 vector of sample weights.
%       Note: When TrueClassLabels and PredictedClassLabels are different, input Weights has not effect and it can be set to empty vector. 
%
% Outputs:
%   ConfusionMatrix: M0xM confusion matrix
%       M0 is the number of integer-valued class labels in Dataset, and
%       M is the number of class lables in decision machine.
%       Usually M0=M.
%       The values in ConfusionMatrix are integer values that count number of decisions. 
%   Pc: Average weighted accuracy over all samples
%       Note: For this value, it is assumed that the sets of
%       TrueClassLabels and PredictedClassLabels ae the same. So, if these
%       two sets are different, Pc = [] is returend.
%
% Revisions:
% 2020-Sep-24   function was created

%% Set Parameters
M0 = length(TrueClassLabels);
M = length(PredictedClassLabels);
ConfusionMatrix = zeros(M0,M);

if isempty(PredictedLabels)
    Pc = [];
    return;
end

%% Calculate Confusion Matrix
ConfusionMatrix = zeros(M0,M);
for i=1:M0
    for j=1:M
        ConfusionMatrix(i,j) = sum(TrueLabels==i & PredictedLabels==j);
    end
end

%% Calculating Pc
if isequal(TrueClassLabels,PredictedClassLabels)
    E = (TrueLabels-PredictedLabels);
    E(E~=0) = 1;
    E = E.*Weights;
    Pc = 100*(1-sum(E)/length(E));
else
    Pc = [];
end
