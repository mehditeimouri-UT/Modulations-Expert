function [SVMModel,SVMModel_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = Build_BinarySVM_ME(Dataset,ClassLabels,FeatureLabels,Weights,TIndex,VIndex,KernelFunction,PolynomialOrder,BoxConstraint,KernelScale)

% This function takes a dataset and trains a binary SVM.
%   Note: SMO (Sequential Minimal Optimization) routine is employed to solve
%   one-norm SVM problem with RBF Kernel.
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
%   KernelFunction: Kernel Function ('rbf', 'linear', or 'polynomial')
%   PolynomialOrder: The order of polynomial when KernelFunction is 'polynomial'
%   BoxConstraint: Value for box constraint in SVM
%   KernelScale: Values for scaling kernel in SVM
%
% Outputs:
%   SVMModel: Final SVM
%   SVMModel_CL: Final SVM with string-value class labels
%   Pc: Average weighted accuracy for binary validation set
%   ConfusionMatrix: The confusion matrix of binary validation data
%   Pc_Train: Average weighted accuracy for binary training set
%   ConfusionMatrix_Train: The confusion matrix of binary training data
%
% Revisions:
% 2020-Sep-24   function was created

%% Train and Validation Sets
Train = Dataset(TIndex,:);
Train_Weights = Weights(TIndex);

Validation = Dataset(VIndex,:);
Validation_Weights = Weights(VIndex);

%% Train SVM using the train set
if isequal(KernelFunction,'polynomial')
    SVMModel = fitcsvm(Train(:,1:end-2),Train(:,end-1),'Weights',Train_Weights,'PredictorNames',FeatureLabels,...
        'BoxConstraint',BoxConstraint,'KernelFunction',KernelFunction,'PolynomialOrder',PolynomialOrder,'KernelScale',KernelScale);
else
    SVMModel = fitcsvm(Train(:,1:end-2),Train(:,end-1),'Weights',Train_Weights,'PredictorNames',FeatureLabels,...
        'BoxConstraint',BoxConstraint,'KernelFunction',KernelFunction,'KernelScale',KernelScale);
end

%% Evaluate the performance of the trained SVM on the training and validation set
label_T = predict(SVMModel,Train(:,1:end-2));
[ConfusionMatrix_Train,Pc_Train] = ConfusionMatrix_ME(Train(:,end-1),label_T,ClassLabels,ClassLabels,Train_Weights);

label_V = predict(SVMModel,Validation(:,1:end-2));
[ConfusionMatrix,Pc] = ConfusionMatrix_ME(Validation(:,end-1),label_V,ClassLabels,ClassLabels,Validation_Weights);

%% Train SVM using the train set
alpha = zeros(size(SVMModel.IsSupportVector));
alpha(SVMModel.IsSupportVector) = SVMModel.Alpha;
SVMModel_CL = fitcsvm(Train(:,1:end-2),ClassLabels(Train(:,end-1)),'Weights',Train_Weights,'PredictorNames',FeatureLabels,...
    'BoxConstraint',BoxConstraint,'KernelFunction','RBF','KernelScale',KernelScale,'Alpha',alpha);