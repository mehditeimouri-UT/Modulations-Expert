function [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = Test_DecisionTree_ME(tree,Dataset,TestIndex,DataClassLabels,TreeClassLabels,DataFeartureLabels,TreeFeartureLabels,Weights)

% This function takes a decision tree and evaluates the performace of the
% tree on a test set. 
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
%   tree: Trained tree
%   Dataset: Dataset with L rows (L samples corresponding to L bursts)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%     
%   Note: Dataset rows are sorted as follows: First, the samples of
%   class 1 appear. Second, the the samples of class 2 appear, and
%   so on. Also for the samples of each class, the bursts with similar file
%   identifier appear consecutively.
%
%   TestIndex: L0*1 vector denoting the index of Test samples.
%   DataClassLabels: 1xM0 cell that contains string labels corresponding to classes in Dataset.
%   TreeClassLabels: 1xM cell that contains string labels corresponding to classes in tree.
%   DataFeartureLabels: 1xF0 cell. Cell contents are strings denoting the name of features in Dataset.
%   TreeFeartureLabels: 1xF cell. Cell contents are strings denoting the name of features in Tree.
%   Weights: Lx1 vector of sample weights. 
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty.
%   Pc: Average of accuracies for final pruned tree on test set.
%   ConfusionMatrix: M0xM confusion matrix 
%       M0 is the number of integer-valued class labels in Dataset, and
%       M is the number of class lables in tree. 
%       Usually M0=M.
%   PredictedLabel: L0*1 vector indicating predicted labels.
%   Scores: L0xlength(TreeClassLabels) matrix. Each row with length M shows the probability for each label. 
%
% Revisions:
% 2020-Sep-24   function was created
% 2021-Jan-15   The Nodes output was removed for compatibility with other
%               MATLAB releases.

%% Initialization
ErrorMsg= '';
Pc = [];
ConfusionMatrix = [];
Scores = [];
PredictedLabel = [];

%% Check Features Compatibility
if ~isequal(DataFeartureLabels,TreeFeartureLabels)
    ErrorMsg = 'Features in Dataset and Decision Tree are incompatible.';
    return;
end

%% Test Set
Test = Dataset(TestIndex,:);
Test_Weights = Weights(TestIndex);

%% Evaluate the performance of the final tree on the test set
[PredictedLabel,Scores] = predict(tree,Test(:,1:end-2));
[ConfusionMatrix,Pc] = ConfusionMatrix_ME(Test(:,end-1),PredictedLabel,DataClassLabels,TreeClassLabels,Test_Weights);