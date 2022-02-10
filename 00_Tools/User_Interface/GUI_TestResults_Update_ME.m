function GUI_TestResults_Update_ME(Filename,TestParameters,TestResults)

% This function updates the Modulations-Expert GUI according to Generated/Loaded Test Results. 
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
%
% Revisions:
% 2020-Sep-24   function was created

%% Initialization
global TestResults_ME_Name_TextBox View_TestResults_PushButton_ME
global TestParameters_ME TestResults_ME

%% Update GUI
set(TestResults_ME_Name_TextBox,'String',Filename);
set(View_TestResults_PushButton_ME,'Enable','on');

%% Update Dataset
TestParameters_ME = TestParameters;
TestResults_ME = TestResults;