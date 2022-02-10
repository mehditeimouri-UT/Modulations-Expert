function ErrorMsg = Script_Load_DecisionMachine_ME

% This function loads DecisionMachine_ME from a mat file
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
% Output:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%
% Revisions:
% 2020-Sep-24   function was created
% 2021-Jan-03   DM_Feature_Transfrom_ME was included

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Load Decision Machine
[Filename,TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,FeatureLabels,ClassLabels,...
    Function_Handles,Function_Labels,Function_Select,Feature_Transfrom,ErrorMsg] = Load_DecisionMachine_ME;
if ~isempty(ErrorMsg)
    return
end

%% Update GUI
GUI_DecisionMachine_Update_ME(Filename,TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,FeatureLabels,ClassLabels,...
    Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_ME(false,'Decision machine is loaded successfully.');