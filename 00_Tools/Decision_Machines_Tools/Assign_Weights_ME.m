function Weights = Assign_Weights_ME(IntegerValuedLabels,ClassLabels,Weighting_Method)

% This function takes the labels of samples in a dataset and assign weights to them in order to
% balance the dataset.
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
%   IntegerValuedLabels: Lx1 vector of interger valued labels of the
%   samples in Dataset
%   ClassLabels: 1x? cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Weighting_Method: Method of weighting that can be 'balanced' or 'uniform'
%       'balanced': Assign weights proportional to inverse of the number of element in each class
%       'uniform': Assign equal weight 1 to all samples.
%
% Outputs:
%   Weights: Lx1 vector, denoting the weights of samples
%       Note: sum(Weights) is equal to length(Weights)
%
% Revisions:
% 2020-Sep-24   function was created

%% Determine weight for each class
M = length(ClassLabels); 
if strcmpi(Weighting_Method,'balanced')
    W = zeros(M,1);
    for j=1:M
        W(j) = sum(IntegerValuedLabels==j);
    end
    W = (sum(W)/length(W))./W;
elseif strcmpi(Weighting_Method,'uniform')
    W = ones(M,1);
end

%% Assign Wieghts such that sum(Weights)==L
Weights = W(IntegerValuedLabels);