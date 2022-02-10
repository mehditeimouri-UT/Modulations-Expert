function ErrorMsg = Script_FeatureSelection_with_PearsonCorrelationCoefficient_ME

% This function takes Dataset_ME with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Use Pearson correlation coefficient to sort and select the features.
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

%% Check that Dataset has at least two classes
if length(ClassLabels_ME)<2
    ErrorMsg = 'At least two classes should be presented.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Assignments
Dataset = Dataset_ME;
FeatureLabels = FeatureLabels_ME;
ClassLabels = ClassLabels_ME;

%% Calculating Pearson Correlation Coefficients
progressbar_ME('Calculating Pearson Correlation Coefficients ...');
RHO = zeros(1,size(Dataset,2)-2);
for j=1:size(Dataset,2)-2
    
    RHO(j) = corr(Dataset(:,j),Dataset(:,end-1));
    
    stopbar = progressbar_ME(1,j/(size(Dataset,2)-2));
    if stopbar
        ErrorMsg = 'Process is aborted by user.';
        return;
    end
    
end

RHO = abs(RHO);
RHO(isnan(RHO)) = 0;

%% Prompt User for Selecting Features
[RHO,idx] = sort(RHO,'descend');
UsedFeatures_Str = cell(1,length(idx));
for j=1:length(idx)
    UsedFeatures_Str{j} = sprintf('Feature #%d: %s (Correlation %0.2f)',j,FeatureLabels{idx(j)},RHO(j));
end

[ErrorMsg,FeatureSel,~] = Select_from_List_ME(UsedFeatures_Str,1,'Select features to be included');
if ~isempty(ErrorMsg)
    return;
end
FeatureSel = FeatureSel{1};
UsedFeatures = FeatureLabels(idx(FeatureSel));

%% Find index of selected features in dataset and remove other features
[~,FeatSel,~] = intersect(FeatureLabels,UsedFeatures);
FeatSel = sort(FeatSel,'ascend');
FeatSel = FeatSel(:)';

Dataset = Dataset(:,[FeatSel end-1:end]);
FeatureLabels = FeatureLabels(FeatSel);

if isempty(Feature_Transfrom_ME)
    
    cnt = 0;
    Function_Select = Function_Select_ME;
    if ~isempty(Function_Select)
        for i=1:length(Function_Select)
            for j=1:length(Function_Select{i})
                if Function_Select{i}(j)
                    cnt = cnt+1;
                    if all(FeatSel~=cnt)
                        Function_Select{i}(j) = false;
                    end
                end
            end
        end
    end
    Feature_Transfrom = [];
    
else
    
    Function_Select = Function_Select_ME;
    Feature_Transfrom.Coef = Feature_Transfrom_ME.Coef(:,FeatSel);
    
end

%% Save Dataset
Function_Handles = Function_Handles_ME;
Function_Labels = Function_Labels_ME;

[Filename,path] = uiputfile('feature_selected_dataset.mat','Save Feature-Selected Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_ME(false,'The process is completed successfully.');
