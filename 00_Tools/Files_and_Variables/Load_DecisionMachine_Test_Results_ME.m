function [Filename,TestParameters,TestResults,ErrorMsg] = Load_DecisionMachine_Test_Results_ME

% This function loads the results of testing a decision machine.
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
% Outputs:
%   Filename: File name corresponding to loaded test results.
%   TestParameters: A structure that specifies the parameters of
%       test. Some of the fields are as follows. Depending on TestParameters.DM_Type
%       there may be more fields.
%           TestParameters.DM_FileName: The filename of the employed
%               decision machine. 
%           TestParameters.DM_Type: Type of decision machine. Type should be be of the following:
%               'Decision Tree', 'SVM', 'Random Forest, ...'.
%           TestParameters.DM_ClassLabels: 1xM cell that contains string labels corresponding to classes in decision machine.
%           TestParameters.Dataset_FileName The filename of the employed
%               dataset. 
%           TestParameters.Dataset_ClassLabels: 1xM0 cell that contains string labels corresponding to classes in dataset.
%           TestParameters.TestIdx: Start and End of the Test in Dataset (1x2 vector with elements 0~1)
%           TestParameters.Weighting_Method: Weighting Method (balanced or
%               uniform)
%   TestResults: A structure that specifies the results of testing. Depending on TestParameters.DM_Type
%       the number of fields for this structre can vary.
%           TestResults.Pc: Average weighted accuracy 
%           TestResults.ConfusionMatrix: M0xM confusion matrix
%           TestResults.TrueLabels: True integer-valued labels for test
%               data in range 1,2,...,M0.
%           TestResults.PredictedLabels: Predicted integer-valued labels
%           for test data in range 1,2,...,M.
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty. 
%
% Revisions:
% 2020-Sep-24   function was created

%% Initialization
ErrorMsg = '';
TestParameters = [];
TestResults = [];

%% Get file from user
[Filename,path] = uigetfile('*.mat','Load the Results of Testing a Decision Machine');
FullFileName = [path Filename];
if isequal(FullFileName,[0 0])
    ErrorMsg = 'No test results file is selected!';
    return;
end

%% Read file
try
    matObj = matfile(FullFileName);
    TestParameters = matObj.TestParameters;    
    TestResults = matObj.TestResults;    
catch
    ErrorMsg = 'Selected file is not a suported file for test results!';
end