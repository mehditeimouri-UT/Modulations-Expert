function GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom)

% This function updates the Modulations-Expert GUI according to Generated/Loaded Dataset. 
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAxR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <http://www.gnu.org/licenses/>.
%
% Inputs:
%   Filename: File name corresponding to loaded/generated Dataset.
%           Dataset: Dataset with NumberofBursts rows (NumberofBursts samples corresponding to NumberofBursts bursts)
%               and C columns. The first NumberofFeatures = C-2 columns correspond to features.
%               The last two columns correspond to the integer-valued class labels
%               and the FileID of the bursts, respectively.
%           FeatureLabels: 1xNumberofFeatures cell. Cell contents are strings denoting the name of
%               features corresponding to the columns of Dataset.
%           ClassLabels: 1xNumberofClasses cell. Cell contents are strings denoting the name of
%               classes corresponding to integer-valued class labels 1,2,....
%
%           Note: Dataset rows are sorted as follows: First, the samples of
%           class 1 (corresponding to the first data file) appear.
%           Second, the the samples of class 2 appear, and so on.
%           Also for the samples of each class, the bursts with similar file
%           identifier appear consecutively.
%
%   Function_Handles: cell array of function handles used for generating
%       dataset.
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%   Feature_Transfrom: A structure which determines the feature tranform if it is non-empty. 
%
% Revisions:
% 2020-Sep-22   function was created
% 2021-Jan-03   Feature_Transfrom input was added

%% Initialization
global Dataset_ME_Name_TextBox Dataset_ME_Classes_TextBox Dataset_ME_Features_TextBox View_Classes_PushButton_ME View_Features_PushButton_ME
global Dataset_ME ClassLabels_ME FeatureLabels_ME
global ClassLabelsandNumbers_ME
global Function_Handles_ME Function_Labels_ME Function_Select_ME
global Feature_Transfrom_ME

%% Manage Inputs
if nargin<8
    Feature_Transfrom = [];
end

%% Update GUI
set(Dataset_ME_Name_TextBox,'String',Filename);
set(Dataset_ME_Classes_TextBox,'String',['Classes: ' num2str(length(ClassLabels))]);
set(Dataset_ME_Features_TextBox,'String',['Features: ' num2str(length(FeatureLabels))]);
set(View_Classes_PushButton_ME,'Enable','on');
set(View_Features_PushButton_ME,'Enable','on');

%% Update Dataset
Dataset_ME = Dataset;
ClassLabels_ME = ClassLabels;
FeatureLabels_ME = FeatureLabels;
Function_Handles_ME = Function_Handles;
Function_Labels_ME = Function_Labels;
Function_Select_ME = Function_Select;
Feature_Transfrom_ME = Feature_Transfrom;
ClassLabelsandNumbers_ME = cell(size(ClassLabels_ME));
for j=1:length(ClassLabels_ME)
    ClassLabelsandNumbers_ME{j} = sprintf('%s: %s samples',ClassLabels_ME{j},num2str(sum(Dataset_ME(:,end-1)==j)));
end