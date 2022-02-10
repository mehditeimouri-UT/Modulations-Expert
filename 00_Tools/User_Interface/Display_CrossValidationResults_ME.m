function Display_CrossValidationResults_ME(CV_Parameters,CV_Results)

% This function visualizes the results of cross-validation for a decision machine.
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
%   CV_Parameters: A structure that specifies the parameters of
%       test. Some of the fields are as follows. Depending on CV_Parameters.DM_Type
%       there may be more fields.
%           CV_Parameters.DM_Type: Type of decision machine. Type should be be of the following:
%               'Decision Tree', 'SVM', 'Random Forest, ...'.
%           CV_Parameters.Dataset_FileName The filename of the employed
%               dataset.
%           CV_Parameters.Dataset_ClassLabels: 1xM cell that contains string labels corresponding to classes in dataset.
%           CV_Parameters.K: The value of K for K-Fold cross-validation
%           CV_Parameters.Weighting_Method: Weighting Method (balanced or
%               uniform)
%   CV_Results: A structure that specifies the results of testing. Depending on CV_Parameters.DM_Type
%       the number of fields for this structre can vary.
%           CV_Results.Pc: Average weighted accuracy
%           CV_Results.ConfusionMatrix: MxM confusion matrix
%           CV_Results.TrueLabels: True integer-valued labels for all
%               samples (in range 1,2,...,M)
%           CV_Results.PredictedLabels: Predicted integer-valued labels
%               for all samples (in range 1,2,...,M).
%
% Revisions:
% 2020-Sep-24   function was created

%% Show Cross-Validation Parameters and Results
GUI_MainEditBox_Update_ME(false,sprintf('Decision Machine Type: %s',CV_Parameters.DM_Type));
GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('Dataset Name: %s',CV_Parameters.Dataset_FileName));

GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('------------ Cross-Validation Parameters -------------'));
GUI_MainEditBox_Update_ME(false,sprintf('K = %d',CV_Parameters.K));
GUI_MainEditBox_Update_ME(false,sprintf('Start/End of Train/Validation/Test = [%g %g]',CV_Parameters.TVTIndex(1),CV_Parameters.TVTIndex(2)));
GUI_MainEditBox_Update_ME(false,sprintf('[Train Validation] = [%g %g]',CV_Parameters.TV(1),CV_Parameters.TV(2)));
GUI_MainEditBox_Update_ME(false,sprintf('Weighting Method: %s',CV_Parameters.Weighting_Method));

% Show Model-Specific Parameters
switch CV_Parameters.DM_Type
    case 'Decision Tree'
        str = num2str(CV_Parameters.MinLeafSize,'%g,');
        GUI_MainEditBox_Update_ME(false,sprintf('Relative MinLeafSize Values: [%s]',str(1:end-1)));
        
    case 'SVM'
        GUI_MainEditBox_Update_ME(false,sprintf('Kernel Function: %s',CV_Parameters.KernelFunction));
        if isequal(CV_Parameters.KernelFunction,'polynomial')
            GUI_MainEditBox_Update_ME(false,sprintf('Polynomial Order: %d',CV_Parameters.PolynomialOrder));
        end
        GUI_MainEditBox_Update_ME(false,sprintf('Scaling Method for featurs: %s',CV_Parameters.feature_scaling_method));
        str = num2str(unique(CV_Parameters.BoxConstraint_MeshGrid(:))','%g,');
        GUI_MainEditBox_Update_ME(false,sprintf('Box Constraint Values: [%s]',str(1:end-1)));
        str = num2str(unique(CV_Parameters.KernelScale_MeshGrid(:))','%g,');
        GUI_MainEditBox_Update_ME(false,sprintf('Kernel Scale Values: [%s]',str(1:end-1)));
        
    case 'Random Forest'
        str = num2str(unique(CV_Parameters.NumTrees_MeshGrid(:))','%d,');
        GUI_MainEditBox_Update_ME(false,sprintf('NumTrees Values: [%s]',str(1:end-1)));
        str = num2str(unique(CV_Parameters.MinLeafSize_MeshGrid(:))','%g,');
        GUI_MainEditBox_Update_ME(false,sprintf('Relative MinLeafSize Values: [%s]',str(1:end-1)));
        
    case 'Ensemble kNN'
        
        GUI_MainEditBox_Update_ME(false,sprintf('Scaling Method for featurs: %s',CV_Parameters.feature_scaling_method));
        GUI_MainEditBox_Update_ME(false,sprintf('Number of random selected features for each kNN learner: %d',CV_Parameters.NumFeatures));
        str = num2str(unique(CV_Parameters.NumLearners_MeshGrid(:))','%d,');
        GUI_MainEditBox_Update_ME(false,sprintf('NumLearners Values: [%s]',str(1:end-1)));
        str = num2str(unique(CV_Parameters.NumNeighbors_MeshGrid(:))','%d,');
        GUI_MainEditBox_Update_ME(false,sprintf('Number of Neighbors Values: [%s]',str(1:end-1)));
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        GUI_MainEditBox_Update_ME(false,sprintf('Scaling Method for featurs: %s',CV_Parameters.feature_scaling_method));
        
    case 'Neural Network'
        GUI_MainEditBox_Update_ME(false,sprintf('Scaling Method for featurs: %s',CV_Parameters.feature_scaling_method));
        str = num2str(CV_Parameters.hiddenSize_Values,'%d,');
        GUI_MainEditBox_Update_ME(false,sprintf('Hidden Layer Size Values Values: [%s]',str(1:end-1)));

end

GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('------------- Cross-Validation Results --------------'));

% Show Model-Specific Results
switch CV_Parameters.DM_Type
    case 'Decision Tree'
        GUI_MainEditBox_Update_ME(false,sprintf('Best Relative MinLeafSize: %g',CV_Results.BestMinLeafSize));
        
    case 'SVM'
        GUI_MainEditBox_Update_ME(false,sprintf('Best BoxConstraint: %g',CV_Results.BestBoxConstraint));
        GUI_MainEditBox_Update_ME(false,sprintf('Best KernelScale: %g',CV_Parameters.BestKernelScale));
        
    case 'Random Forest'
        GUI_MainEditBox_Update_ME(false,sprintf('Best NumTrees: %d',CV_Results.BestNumTrees));
        GUI_MainEditBox_Update_ME(false,sprintf('Best MinLeafSize: %g',CV_Results.BestMinLeafSize));
        
    case 'Ensemble kNN'
        GUI_MainEditBox_Update_ME(false,sprintf('Best NumLearners: %d',CV_Results.BestNumLearners));
        GUI_MainEditBox_Update_ME(false,sprintf('Best Number of Neighbors: %d',CV_Results.BestNumNeighbors));
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        
    case 'Neural Network'
        GUI_MainEditBox_Update_ME(false,sprintf('Best Hidden Layer Size: %d',CV_Results.BesthiddenSize));

end

if isempty(CV_Results.Pc_Validation)
    valstr = 'x';
else
    valstr = sprintf('%0.2f',CV_Results.Pc_Validation);
end

GUI_MainEditBox_Update_ME(false,' ');
GUI_MainEditBox_Update_ME(false,sprintf('Average weighted accuracy for training, validation and test: %0.2f%% - %s%% - %0.2f%%',CV_Results.Pc_Train,valstr,CV_Results.Pc));
GUI_MainEditBox_Update_ME(false,' ');

GUI_MainEditBox_Update_ME(false,sprintf('Confusion matrix for cross-validation (training phase) is shown in command window.'));
ShowConfusionMatrix_ME(CV_Results.ConfusionMatrix_Train,CV_Parameters.Dataset_ClassLabels,CV_Parameters.Dataset_ClassLabels,'Confusion Matrix for Training Set');
if ~isempty(CV_Results.Pc_Validation)
    GUI_MainEditBox_Update_ME(false,sprintf('Confusion matrix for cross-validation (validation phase) is shown in command window.'));
    ShowConfusionMatrix_ME(CV_Results.ConfusionMatrix_Validation,CV_Parameters.Dataset_ClassLabels,CV_Parameters.Dataset_ClassLabels,'Confusion Matrix for Validation Set');
end
GUI_MainEditBox_Update_ME(false,sprintf('Confusion matrix for cross-validation (test phase) is shown in command window.'));
ShowConfusionMatrix_ME(CV_Results.ConfusionMatrix,CV_Parameters.Dataset_ClassLabels,CV_Parameters.Dataset_ClassLabels,'Confusion Matrix for Test Set');
GUI_MainEditBox_Update_ME(false,' ');

%% Display Curves
switch CV_Parameters.DM_Type
    case 'Decision Tree'
        
        % Show 2-D curve for Decision Tree Parameters Tuning
        figure('Name','Accuracy curve of decision tree in cross-validation','NumberTitle','off','WindowStyle','normal');
        plot(CV_Parameters.MinLeafSize,cell2mat(CV_Results.Pc_Tune),'-*')
        xlabel('Relative MinLeafSize')
        ylabel('Weighted Accuracy for Test (%)')
        
    case 'SVM'
        
        % Show 3-D curve for SVM Parameters Tuning
        if all(size(CV_Parameters.BoxConstraint_MeshGrid)>1)
            figure('Name',sprintf('Grid Search Results for Multi-Class SVM'),'NumberTitle','off','WindowStyle','normal');
            surf(CV_Parameters.BoxConstraint_MeshGrid,CV_Parameters.KernelScale_MeshGrid,...
                reshape(cell2mat(CV_Results.Pc_Tune),size(CV_Parameters.KernelScale_MeshGrid)));
            xlabel('C')
            ylabel('\sigma')
            zlabel('Average Weighted Accuracy')
            
        end
        
    case 'Random Forest'
        
        % Show 3-D curve for Random Forest Parameters Tuning
        if all(size(CV_Parameters.NumTrees_MeshGrid)>1)
            figure('Name',sprintf('Grid Search Results for Random Forest'),'NumberTitle','off','WindowStyle','normal');
            surf(CV_Parameters.NumTrees_MeshGrid,CV_Parameters.MinLeafSize_MeshGrid,...
                reshape(cell2mat(CV_Results.Pc_Tune),size(CV_Parameters.NumTrees_MeshGrid)));
            xlabel('NumTrees')
            ylabel('MinLeafSize')
            zlabel('Average Weighted Accuracy')
            
        end
        
    case 'Ensemble kNN'
        
        % Show 3-D curve for Ensemble kNN Parameters Tuning
        if all(size(CV_Parameters.NumLearners_MeshGrid)>1)
            figure('Name',sprintf('Grid Search Results for Ensemble kNN'),'NumberTitle','off','WindowStyle','normal');
            surf(CV_Parameters.NumLearners_MeshGrid,CV_Parameters.NumNeighbors_MeshGrid,...
                reshape(cell2mat(CV_Results.Pc_Tune),size(CV_Parameters.NumLearners_MeshGrid)));
            xlabel('NumLearners')
            ylabel('NumNeighbors')
            zlabel('Average Weighted Accuracy')
            
        end
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}

        
    case 'Neural Network'
        
        % Show 2-D curve for Neural Network Parameters Tuning        
        figure('Name','Accuracy curve of neural network in cross-validation ','NumberTitle','off','WindowStyle','normal');
        plot(CV_Parameters.hiddenSize_Values,cell2mat(CV_Results.Pc_Tune),'-*')
        xlabel('Hidden Layer Size')
        ylabel('Weighted Accuracy for Test (%)')             
        
end