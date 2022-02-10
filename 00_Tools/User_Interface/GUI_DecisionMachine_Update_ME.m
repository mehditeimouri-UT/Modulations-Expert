function GUI_DecisionMachine_Update_ME(Filename,TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,FeatureLabels,ClassLabels,...
    Function_Handles,Function_Labels,Function_Select,Feature_Transfrom)

                                        
% This function updates the Modulations-Expert GUI according to Generated/Loaded Decision Machine. 
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
%   Filename: File name corresponding to loaded/generated Decision Machine.
%   TrainingParameters: A structure that specifies the parameters for
%       training. Some of the fields are as follows. Depending on TrainingParameters.Type
%       there may be more fields.
%           TrainingParameters.Type: Type of decision machine. Type should be be of the following:
%           'Decision Tree', 'SVM', 'Random Forest, ...'.
%           TrainingParameters.DatasetName: The name of the employed Dataset
%   TrainingResults: A structure that specifies the results of training. Depending on TrainingParameters.Type
%       the number of fields for this structre can vary.
%   DecisionMachine: Decision Machine MATLAB Object
%   DecisionMachine_CL: Decision Machine MATLAB Object
%
%   Note: DecisionMachine_CL and DecisionMachine are basically the same. In
%   DecisionMachine_CL, class labels are string values. In DecisionMachine, 
%   class labels are integer values.
%
%   FeatureLabels: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to DecisionMachine.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued DecisionMachine class labels 1,2,....
%   Function_Handles: cell array of function handles used for generating
%       dataset. 
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%   Feature_Transfrom: A structure which determines the feature tranform if it is non-empty. 
%     
% Revisions:
% 2020-Sep-24   function was created
% 2021-Jan-03   DM_Feature_Transfrom_ME was included

%% Initialization
global DecisionMachine_ME_Name_TextBox DecisionMachine_ME_Validation_TextBox View_Decision_Machine_PushButton_ME
global DM_TrainingParameters_ME DM_TrainingResults_ME DecisionMachine_ME DecisionMachine_CL_ME DM_ClassLabels_ME DM_FeatureLabels_ME
global DM_Function_Handles_ME DM_Function_Labels_ME DM_Function_Select_ME DM_Feature_Transfrom_ME

%% Update GUI
set(DecisionMachine_ME_Name_TextBox,'String',Filename);
if isempty(TrainingResults.Pc)
    set(DecisionMachine_ME_Validation_TextBox,'String',sprintf('x%%'));
else
    set(DecisionMachine_ME_Validation_TextBox,'String',sprintf('Validation Accuracy: %0.2f%%',TrainingResults.Pc));
end
set(View_Decision_Machine_PushButton_ME,'Enable','on');

%% Update Dataset
DM_TrainingParameters_ME = TrainingParameters;
DM_TrainingResults_ME = TrainingResults;
DecisionMachine_ME  = DecisionMachine;
DecisionMachine_CL_ME  = DecisionMachine_CL;
DM_ClassLabels_ME = ClassLabels; 
DM_FeatureLabels_ME = FeatureLabels;
DM_Function_Handles_ME = Function_Handles;
DM_Function_Labels_ME = Function_Labels;
DM_Function_Select_ME = Function_Select;
DM_Feature_Transfrom_ME = Feature_Transfrom;