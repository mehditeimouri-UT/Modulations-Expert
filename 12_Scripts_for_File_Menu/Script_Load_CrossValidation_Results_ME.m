function ErrorMsg = Script_Load_CrossValidation_Results_ME

% This function loads and displays the results of cross-validation for a decision machine.
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
% Output:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%
% Revisions:
% 2020-Sep-24   function was created

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Load Decision Machine
[Filename,CV_Parameters,CV_Results,ErrorMsg] = Load_CrossValidation_Results_ME;
if ~isempty(ErrorMsg)
    return
end

%% Update GUI
GUI_CrossValidationResults_Update_ME(Filename,CV_Parameters,CV_Results);
GUI_MainEditBox_Update_ME(false,'The results of cross-validation are loaded successfully.');