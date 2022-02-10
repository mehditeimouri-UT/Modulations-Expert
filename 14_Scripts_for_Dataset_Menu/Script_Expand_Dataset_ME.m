function ErrorMsg = Script_Expand_Dataset_ME

% This function expands Dataset_ME using an aready-saved Dataset from a mat file
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
% 2020-Sep-23   function was created
% 2021-Jan-03   Feature_Transfrom_ME was included

%% Initialization
global ClassLabels_ME FeatureLabels_ME Dataset_ME
global Function_Handles_ME Function_Labels_ME Function_Select_ME
global Feature_Transfrom_ME

%% Check that Dataset is generated/loaded
if isempty(Dataset_ME)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Load the Old Dataset
[~,Dataset_Old,FeatureLabels_Old,ClassLabels_Old,Function_Handles_Old,Function_Labels_Old,Function_Select_Old,Feature_Transfrom_Old,ErrorMsg] = Load_Dataset_ME('Load the Old Dataset');
if ~isempty(ErrorMsg)
    return;
end

%% Expand the Old Dataset
[ErrorMsg,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom] = ...
    Expand_Dataset_ME(Dataset_ME,FeatureLabels_ME,ClassLabels_ME,Function_Handles_ME,Function_Labels_ME,Function_Select_ME,Feature_Transfrom_ME,...
    Dataset_Old,FeatureLabels_Old,ClassLabels_Old,Function_Handles_Old,Function_Labels_Old,Function_Select_Old,Feature_Transfrom_Old);
if ~isempty(ErrorMsg)
    return;
end

%% Save Expanded Dataset
[Filename,path] = uiputfile('mydataset_expanded.mat','Save Expanded Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving expanded dataset.';
    return;
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');


%% Update GUI
GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_ME(false,'The process of Dataset Expansion is completed successfully.');