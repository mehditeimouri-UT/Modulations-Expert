function [NaiveBayes,NaiveBayes_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = Build_NaiveBayes_ME(Dataset,ClassLabels,FeatureLabels,Weights,TIndex,VIndex)

% This function takes a dataset and trains a Naive Bayes model. 
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
%
% Outputs:
%   NaiveBayes: Naive Bayes model with integer values class labels
%   NaiveBayes_CL: Naive Bayes model with string class labels taken from ClassLabels
%   Pc: Average weighted accuracy over all samples of validation set
%   ConfusionMatrix: Confusion matrix for validation data
%   Pc_Train: Average weighted accuracy over all samples of training set
%   ConfusionMatrix_Train: Confusion matrix for training data
%
% Revisions:
% 2020-Sep-24   function was created

%% Train Set
Train = Dataset(TIndex,:);
Train_Weights = Weights(TIndex);

%% Train Naive Bayes
NaiveBayes = fitcnb(Train(:,1:end-2),Train(:,end-1),'DistributionNames','kernel','Kernel','normal',...
    'PredictorNames',FeatureLabels,'Weights',Train_Weights);

NaiveBayes_CL = fitcnb(Train(:,1:end-2),ClassLabels(Train(:,end-1)),'DistributionNames','kernel','Kernel','normal',...
    'PredictorNames',FeatureLabels,'Weights',Train_Weights);

%% Evaluate the performance of Naive Bayes Using Training and Validation Set
[~,Pc_Train,ConfusionMatrix_Train,~,~] = Test_NaiveBayes_ME(NaiveBayes,Dataset,TIndex,ClassLabels,ClassLabels,FeatureLabels,FeatureLabels,Weights);
[~,Pc,ConfusionMatrix,~,~] = Test_NaiveBayes_ME(NaiveBayes,Dataset,VIndex,ClassLabels,ClassLabels,FeatureLabels,FeatureLabels,Weights);