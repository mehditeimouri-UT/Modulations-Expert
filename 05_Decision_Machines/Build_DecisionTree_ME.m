function [Tree,Tree_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train,stopbar] = Build_DecisionTree_ME(Dataset,ClassLabels,FeatureLabels,Weights,TIndex,VIndex,MinLeafSize,prg_idx)

% This function takes a dataset and trains a decision tree. 
%   Decision tree training method:
%       (1) Growing tree: A recursive splitting algorithm based on Gini’s
%       diversity index is used with MinLeafSize 1
%       (2) Pruning tree: Cost-complexity post-pruning method is employed and
%       the tree with maximum average accuracy over all classes in
%       validation set is considered.
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
%   Dataset: Dataset with L rows (L samples corresponding to L bursts)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   FeatureLabels: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%     
%   Note: Dataset rows are sorted as follows: First, the samples of
%   class 1 appear. Second, the the samples of class 2 appear, and
%   so on. Also for the samples of each class, the bursts with similar file
%   identifier appear consecutively.
%
%   Weights: Lx1 vector of sample weights. 
%   TIndex: L1x1 indices of training samples
%   VIndex: L2x1 indices of validation samples
%   MinLeafSize: Minimum relative number of leaf node observations to total samples (0~1)
%   prg_idx: Indication of using progressbar function
%       0: Means no progressbar is needed.
%       1: Means that the 1st progressbar should be used to indicate progress.
%       2: Means that the 2nd progressbar should be used to indicate progress.
%       3: Means that the 3rd progressbar should be used to indicate progress.
%
% Outputs:
%   Tree: Final pruned tree
%   Tree_CL: Final pruned tree with string class labels taken from ClassLabels
%   Pc: Average weighted accuracy over all samples of validation set for the selected pruned tree 
%   ConfusionMatrix: Confusion matrix for validation data
%   Pc_Train: Average weighted accuracy over all samples of training set for the selected pruned tree 
%   ConfusionMatrix_Train: Confusion matrix for training data
%   stopbar: If true, it means that the user has terminated the process. 
%
% Revisions:
% 2020-Sep-24   function was created

%% Train and Validation Sets
Train = Dataset(TIndex,:);
Train_Weights = Weights(TIndex);

Validation = Dataset(VIndex,:);
Validation_Weights = Weights(VIndex);

%% Train the initial tree using the train set
tree = fitctree(Train(:,1:end-2),Train(:,end-1),'MinLeafSize',ceil(MinLeafSize*size(Train,1)),'Weights',Train_Weights,'PredictorNames',FeatureLabels);

%% consider Various Pruning
levels = 0:numel(tree.PruneAlpha)-1;
Pcs = zeros(size(levels));
progressbar_ME(prg_idx,eps);
cnt = 0;
for level = levels
    
    % Prune the tree
    cnt = cnt+1;
    ptree = prune(tree,'level',level);

    % Evaluate the performance of the pruned tree on the validation set 
    label_V = predict(ptree,Validation(:,1:end-2));
    [~,Pcs(cnt)] = ConfusionMatrix_ME(Validation(:,end-1),label_V,ClassLabels,ClassLabels,Validation_Weights);

    % progress indication
    stopbar = progressbar_ME(prg_idx,cnt/length(levels));
    if stopbar
        Tree = [];
        Tree_CL = [];
        Pc = [];
        ConfusionMatrix = [];
        Pc_Train = [];
        ConfusionMatrix_Train = [];
        return;
    end
    
end

%% Find the best pruned tree
maxval = max(Pcs);
selidx = find(Pcs>=maxval,1,'last'); % Select the smallest possible sub-tree
level = levels(selidx);
Tree = prune(tree,'level',level);
Pc = Pcs(selidx);

%% Evaluate the performance of Decision Tree Using Training and Validation Sets
label_T = predict(Tree,Train(:,1:end-2));
[ConfusionMatrix_Train,Pc_Train] = ConfusionMatrix_ME(Train(:,end-1),label_T,ClassLabels,ClassLabels,Train_Weights);

label_V = predict(Tree,Validation(:,1:end-2));
ConfusionMatrix = ConfusionMatrix_ME(Validation(:,end-1),label_V,ClassLabels,ClassLabels,Validation_Weights);

%% Best pruned tree with string class labels taken from ClassLabels
tree = fitctree(Train(:,1:end-2),ClassLabels(Train(:,end-1)),'MinLeafSize',ceil(MinLeafSize*size(Train,1)),'Weights',Train_Weights,'PredictorNames',FeatureLabels);
Tree_CL = prune(tree,'level',level);