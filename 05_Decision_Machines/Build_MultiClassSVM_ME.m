function [SVMModel_j,SVMModel_CL_j,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train,Pc_j,ConfusionMatrix_j,Pc_Train_j,ConfusionMatrix_Train_j,stopbar] = ...
    Build_MultiClassSVM_ME(Dataset,ClassLabels,FeatureLabels,Weights,Weighting_Method,TIndex,VIndex,KernelFunction,PolynomialOrder,BoxConstraint,KernelScale,prg_idx)

% This function takes a dataset and trains a multi-class SVM
%   SVM training method: 
%       Approach: M binary SVMs (one-against-all) are trained. 
%       Training SVM: SMO (Sequential Minimal Optimization) routine is employed to solve 
%           one-norm SVM problem with RBF Kernel.
%       Validating SVM: A grid search is employed to find the best values of BoxConstraint 
%           and KernelScale for each binary SVM classifier. 
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
%   Weighting_Method: Weighting Method ('balanced' or 'uniform')
%   Weights: Lx1 vector of sample weights. 
%   TIndex: L1x1 indices of training samples
%   VIndex: L2x1 indices of validation samples
%   KernelFunction: Kernel Function ('rbf', 'linear', or 'polynomial')
%   PolynomialOrder: The order of polynomial when KernelFunction is 'polynomial'
%   BoxConstraint: Value for box constraint in SVM
%   KernelScale: Value for scaling kernel in SVM
%   prg_idx: Indication of using progressbar function
%       0: Means no progressbar is needed.
%       1: Means that the 1st progressbar should be used to indicate progress.
%       2: Means that the 2nd progressbar should be used to indicate progress.
%       3: Means that the 3rd progressbar should be used to indicate progress.
%
% Outputs:
%   SVMModel_j: A cell array; each element is jth binary SVM
%   SVMModel_CL_j: A cell array; each element is jth binary SVM with string class labels taken from ClassLabels
%   Pc: Average weighted accuracy over all samples of validation set for final multi-class SVM 
%   ConfusionMatrix: The confusion matrix of validation data for final multi-class SVM  
%   Pc_Train: Average weighted accuracy over all samples of training set for final multi-class SVM 
%   ConfusionMatrix_Train: The confusion matrix of training data for final multi-class SVM  
%   Pc_j: A cell array; each element is the average weighted accuracies of validation set for corresponding binary SVM classifier
%   ConfusionMatrix_j: A cell array; each element is confusion matrix of validation data for corresponding binary SVM classifier  
%   Pc_Train_j: A cell array; each element is the average weighted accuracies of training set for corresponding binary SVM classifier
%   ConfusionMatrix_Train_j: A cell array; each element is confusion matrix of training data for corresponding binary SVM classifier  
%   stopbar: If true, it means that the user has terminated the process. 
%
% Revisions:
% 2020-Sep-24   function was created

%% Prepare outputs
M = length(ClassLabels);
SVMModel_j = cell(1,M); % jth binary classifier
SVMModel_CL_j = cell(1,M); % jth binary classifier with string class labels
Pc_j = cell(1,M); % A cell array; each element is the average weighted accuracies of validation set for corresponding binary SVM classifier
ConfusionMatrix_j = cell(1,M); % A cell array; each element is confusion matrix of validation data for final multi-class SVM  
Pc_Train_j = cell(1,M); % A cell array; each element is the average weighted accuracies of training set for corresponding binary SVM classifier
ConfusionMatrix_Train_j = cell(1,M); % A cell array; each element is confusion matrix of training data for final multi-class SVM  

%% Train M Binary one-against-all classifier
progressbar_ME(prg_idx,eps);
for j=1:M
    
    % Prepare binary-labeld Dataset
    Datasetj = Dataset;
    idx = Datasetj(:,end-1)~=j;
    Datasetj(idx,end-1) = 0;
    Datasetj(~idx,end-1) = 1;
    Datasetj(:,end-1) = Datasetj(:,end-1)+1;
    ClassLabelsj = {['Non' ClassLabels{j}] ClassLabels{j}};
    Weightsj = Assign_Weights_ME(Datasetj(:,end-1),ClassLabelsj,Weighting_Method);
    
    % Train binary SVM
    [SVMModel_j{j},SVMModel_CL_j{j},Pc_j{j},ConfusionMatrix_j{j},Pc_Train_j{j},ConfusionMatrix_Train_j{j}] = ...
        Build_BinarySVM_ME(Datasetj,ClassLabelsj,FeatureLabels,Weightsj,TIndex,VIndex,KernelFunction,PolynomialOrder,BoxConstraint,KernelScale);
    
    % Progress
    stopbar = progressbar_ME(prg_idx,j/M);
    if stopbar
        SVMModel_j = [];
        SVMModel_CL_j = [];
        Pc = [];
        ConfusionMatrix = [];
        Pc_Train = [];
        ConfusionMatrix_Train = [];
        Pc_j = [];
        ConfusionMatrix_j = [];
        Pc_Train_j = [];
        ConfusionMatrix_Train_j = [];
        return;
    end
    
end

%% Evaluate the performance of Final SVM Model Using Training and Validation Set
[~,Pc_Train,ConfusionMatrix_Train,~,~] = Test_MultiClassSVM_ME(SVMModel_j,Dataset,TIndex,ClassLabels,ClassLabels,FeatureLabels,FeatureLabels,Weights);
[~,Pc,ConfusionMatrix,~,~] = Test_MultiClassSVM_ME(SVMModel_j,Dataset,VIndex,ClassLabels,ClassLabels,FeatureLabels,FeatureLabels,Weights);
