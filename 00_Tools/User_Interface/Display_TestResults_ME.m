function Display_TestResults_ME(TestParameters,TestResults)

% This function visualizes the results of testing a decision machine. 
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
%
% Revisions:
% 2020-Sep-24   function was created

%% Show Test Parameters and Results
GUI_MainEditBox_Update_ME(false,sprintf('Decision Machine Name: %s',TestParameters.DM_FileName));
GUI_MainEditBox_Update_ME(false,sprintf('Decision Machine Type: %s',TestParameters.DM_Type));
GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('Dataset Name: %s',TestParameters.Dataset_FileName));

GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('------------ Test Parameters -------------'));
GUI_MainEditBox_Update_ME(false,' ');
GUI_MainEditBox_Update_ME(false,sprintf('Start and End of Test in Dataset: [%g %g]',TestParameters.TestIdx(1),TestParameters.TestIdx(2)));
GUI_MainEditBox_Update_ME(false,sprintf('Weighting Method: %s',TestParameters.Weighting_Method));

GUI_MainEditBox_Update_ME(false,sprintf(' '));
GUI_MainEditBox_Update_ME(false,sprintf('------------- Test Results --------------'));
GUI_MainEditBox_Update_ME(false,' ');
if ~isempty(TestResults.Pc)
    GUI_MainEditBox_Update_ME(false,sprintf('Average weighted accuracy on test set: %0.2f%%',TestResults.Pc));
    GUI_MainEditBox_Update_ME(false,' ');
end

%% Show Confusion Matrix
GUI_MainEditBox_Update_ME(false,sprintf('Confusion matrix for test data is shown in command window.'));
ShowConfusionMatrix_ME(TestResults.ConfusionMatrix,TestParameters.Dataset_ClassLabels,TestParameters.DM_ClassLabels,'Confusion Matrix for Test Set');
GUI_MainEditBox_Update_ME(false,' ');