function Display_DecisionMachine_ME(TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,ClassLabels)

% This function visualizes the properties of a decision machine.
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
%   TrainingParameters: A structure that specifies the parameters for
%       training. Some of the fields are as follows. Depending on TrainingParameters.Type
%       there may be more fields.
%           TrainingParameters.Type: Type of decision machine. Type should be be of the following:
%               'Decision Tree', 'SVM', 'Random Forest, ...'.
%           TrainingParameters.DatasetName: The name of the employed Dataset
%   TrainingResults: A structure that specifies the results of training. Depending on TrainingParameters.Type
%       the number of fields for this structre can vary.
%   DecisionMachine: Decision Machine MATLAB Object with integer valeue class labels
%   DecisionMachine_CL: Decision Machine MATLAB Object with string class labels
%
% Revisions:
% 2020-Sep-24   function was created

%% Show General Parameters
GUI_MainEditBox_Update_ME(false,sprintf('Decision Machine Type: %s',TrainingParameters.Type));
GUI_MainEditBox_Update_ME(false,sprintf('Dataset Name: %s',TrainingParameters.DatasetName));

GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('------------ Training Parameters -------------'));
GUI_MainEditBox_Update_ME(false,' ');
GUI_MainEditBox_Update_ME(false,sprintf('Weighting Method: %s',TrainingParameters.Weighting_Method));
GUI_MainEditBox_Update_ME(false,sprintf('Start and End of the Train/Validation in Dataset: [%g %g]',TrainingParameters.TVIndex(1),TrainingParameters.TVIndex(2)));
GUI_MainEditBox_Update_ME(false,sprintf('Train and Validation Percentages: [%g %g]',TrainingParameters.TV(1),TrainingParameters.TV(2)));

%% Show Model-Specific Parameters
switch TrainingParameters.Type
    case 'Decision Tree'
        
        % Show Training Parameters
        GUI_MainEditBox_Update_ME(false,sprintf('MinLeafSize: %g',TrainingParameters.MinLeafSize));
        
        % Show Decision Tree
        view(DecisionMachine_CL,'Mode','graph');
        
    case 'SVM'
        
        % Show Training Parameters
        GUI_MainEditBox_Update_ME(false,sprintf('Method of Feature Scaling: %s',TrainingParameters.feature_scaling_method));
        GUI_MainEditBox_Update_ME(false,sprintf('Kernel Function: %s',TrainingParameters.KernelFunction));
        if isequal(TrainingParameters.KernelFunction,'polynomial')
            GUI_MainEditBox_Update_ME(false,sprintf('Polynomial Order: %d',TrainingParameters.PolynomialOrder));
        end
        GUI_MainEditBox_Update_ME(false,sprintf('Box Constraint: %g',TrainingParameters.BoxConstraint));
        GUI_MainEditBox_Update_ME(false,sprintf('Kernel Scale: %g',TrainingParameters.KernelScale));
        
    case 'Random Forest'
        
        % Show Training Parameters
        GUI_MainEditBox_Update_ME(false,sprintf('MinLeafSize: %g',TrainingParameters.MinLeafSize));
        GUI_MainEditBox_Update_ME(false,sprintf('Number of Trees: %d',TrainingParameters.NumTrees));
        
    case 'Ensemble kNN'
        
        % Show Training Parameters
        GUI_MainEditBox_Update_ME(false,sprintf('Method of Feature Scaling: %s',TrainingParameters.feature_scaling_method));
        GUI_MainEditBox_Update_ME(false,sprintf('Number of random selected features for each kNN learner: %d',TrainingParameters.NumFeatures));
        GUI_MainEditBox_Update_ME(false,sprintf('Number of kNN learners in ensemble: %d',TrainingParameters.NumLearners));
        GUI_MainEditBox_Update_ME(false,sprintf('Number of nearest neighbors for classifying each point: %d',TrainingParameters.NumNeighbors));
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        
        % Show Training Parameters
        GUI_MainEditBox_Update_ME(false,sprintf('Method of Feature Scaling: %s',TrainingParameters.feature_scaling_method));
        
    case 'Neural Network'
        % Show Training Parameters
        GUI_MainEditBox_Update_ME(false,sprintf('Method of Feature Scaling: %s',TrainingParameters.feature_scaling_method));
        GUI_MainEditBox_Update_ME(false,sprintf('Hidden Layer Size: %d',TrainingParameters.hiddenSize));
        
        % Show Neural Network
        view(DecisionMachine);
end


%% Show Confusion Matrix for Validation Data
GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('------------- Training Results --------------'));

if isempty(TrainingResults.Pc)
    valstr = 'x';
else
    valstr = sprintf('%0.2f',TrainingResults.Pc);
end

GUI_MainEditBox_Update_ME(false,' ');
GUI_MainEditBox_Update_ME(false,sprintf('Average weighted accuracy on training and validation set: %0.2f%% - %s%%',TrainingResults.Pc_Train,valstr));
GUI_MainEditBox_Update_ME(false,' ');

GUI_MainEditBox_Update_ME(false,sprintf('Confusion matrix for training data is shown in command window.'));
ShowConfusionMatrix_ME(TrainingResults.ConfusionMatrix_Train,ClassLabels,ClassLabels,'Confusion Matrix for Training Set');
if ~isempty(TrainingResults.Pc)
    GUI_MainEditBox_Update_ME(false,sprintf('Confusion matrix for validation data is shown in command window.'));
    ShowConfusionMatrix_ME(TrainingResults.ConfusionMatrix,ClassLabels,ClassLabels,'Confusion Matrix for Validation Set');
end
GUI_MainEditBox_Update_ME(false,' ');