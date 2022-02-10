function [Filename,TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,FeatureLabels,ClassLabels,...
    Function_Handles,Function_Labels,Function_Select,Feature_Transfrom,ErrorMsg] = Load_DecisionMachine_ME

% This function loads a decision machine.
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
% Outputs:
%   Filename: File name corresponding to loaded decision machine.
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
%       classes corresponding to integer-valued DecisionMachine class labels 
%   Function_Handles: cell array of function handles used for generating
%       dataset. 
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%   Feature_Transfrom: A structure which determines the feature tranform if it is non-empty. 
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty. 
%
% Revisions:
% 2020-Sep-24   function was created
% 2021-Jan-03   Feature_Transfrom output was included

%% Initialization
ErrorMsg = '';
TrainingParameters = [];
TrainingResults = [];
DecisionMachine = [];
DecisionMachine_CL = [];
FeatureLabels = [];
ClassLabels = [];
Function_Handles = [];
Function_Labels = [];
Function_Select = [];
Feature_Transfrom = [];

%% Get file from user
[Filename,path] = uigetfile('*.mat','Load Decision Machine');
FullFileName = [path Filename];
if isequal(FullFileName,[0 0])
    ErrorMsg = 'No decision machine file is selected!';
    return;
end

%% Read file
try
    matObj = matfile(FullFileName);
    TrainingParameters = matObj.TrainingParameters;    
    TrainingResults = matObj.TrainingResults;    
    DecisionMachine = matObj.DecisionMachine;
    DecisionMachine_CL = matObj.DecisionMachine_CL;
    ClassLabels = matObj.ClassLabels;
    FeatureLabels = matObj.FeatureLabels;
    Function_Handles = matObj.Function_Handles;
    Function_Labels = matObj.Function_Labels;
    Function_Select = matObj.Function_Select;
    try 
        Feature_Transfrom = matObj.Feature_Transfrom;
    catch
        Feature_Transfrom = [];
    end
catch
    ErrorMsg = 'Selected file is not a suported decision tree!';
end