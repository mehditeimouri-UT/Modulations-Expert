function ErrorMsg = Script_FeatureSelection_with_PCA_ME

% This function takes Dataset_ME with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Use feature transformation method of principal component analysis (PCA) to obtain the new set of features.
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
% 2020-Nov-12   function was created
% 2021-Jan-03   Feature_Transfrom_ME was defined and included

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

%% Assignments
ClassLabels = ClassLabels_ME;
FeatureLabels = cell(1,length(FeatureLabels_ME));
for j=1:length(FeatureLabels_ME)
    FeatureLabels{j} = sprintf('PCA_%d',j);
end

%% Applying PCA
Dataset = zeros(size(Dataset_ME));
[Coef,~,feat_eigs] = pca(Dataset_ME(:,1:end-2));
Dataset(:,1:end-2) = Dataset_ME(:,1:end-2)*Coef;
Dataset(:,end-1:end) = Dataset_ME(:,end-1:end);

%% Prompt User for Selecting Features
UsedFeatures_Str = cell(1,length(FeatureLabels_ME));
for j=1:length(FeatureLabels_ME)
    UsedFeatures_Str{j} = sprintf('Feature #%d: %s (Eigen-Value  %g)',j,FeatureLabels{j},feat_eigs(j));
end

[ErrorMsg,FeatureSel,~] = Select_from_List_ME(UsedFeatures_Str,1,'Select features to be included');
if ~isempty(ErrorMsg)
    return;
end
FeatureSel = FeatureSel{1};
UsedFeatures = FeatureLabels(FeatureSel);

%% Find index of selected features in dataset and remove other features
[~,FeatSel,~] = intersect(FeatureLabels,UsedFeatures);
FeatSel = sort(FeatSel,'ascend');
FeatSel = FeatSel(:)';

Dataset = Dataset(:,[FeatSel end-1:end]);
FeatureLabels = FeatureLabels(FeatSel);

%% Modify Feature_Transfrom
Feature_Transfrom = Feature_Transfrom_ME;
if isempty(Feature_Transfrom)
    Feature_Transfrom.Coef = Coef(:,FeatSel);
else
    Feature_Transfrom.Coef = Feature_Transfrom.Coef*Coef(:,FeatSel);
end

%% Save Dataset
Function_Handles = Function_Handles_ME;
Function_Labels = Function_Labels_ME;
Function_Select = Function_Select_ME;

[Filename,path] = uiputfile('feature_selected_dataset.mat','Save Feature-Selected Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_ME(false,'The process is completed successfully.');
