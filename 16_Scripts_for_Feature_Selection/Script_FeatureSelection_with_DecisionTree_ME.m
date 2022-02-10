function ErrorMsg = Script_FeatureSelection_with_DecisionTree_ME

% This function takes Dataset_ME with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Train a decision machine using train/validation data and select the
%     features used for building the final pruned tree.
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

%% Parameters
Param_Names = {'Weighting_Method','TVIndex','TV','MinLeafSize'};
Param_Description = {'Weighting Method (balanced or uniform)',...
    'Start and End of the Train/Validation in Dataset (1x2 vector with elements 0~1)',...
    'Train and Validation Percentages Taken from Dataset (1x2 vector with sum ==100, Train>=70 and Validation>=15)',...
    'Minimum relative number of leaf node observations to total samples (1e-5~0.1)'};
Default_Value = {'balanced','[0 1]','[80 20]','0.001'};

dlg_title = 'Parameters for Feature Selection';
str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title);
eval(str_cmd);

if ~success
    ErrorMsg = sprintf('Process is aborted. Parameters for Feature Selection are not specified');
    return;
end

%% Check Parameters
ErrMsg = Check_Variable_Value_ME(Weighting_Method,'Weighting Method','possiblevalues',{'balanced','uniform'});
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(TV,'Train and Validation Percentages','type','vector','class','real','size',[1 2],'sum',100,'min',0);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(TV(1),'Train Percentage','type','scalar','class','real','min',70);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

PartitionGenerateError = [true true];
ErrMsg = Check_Variable_Value_ME(TV(2),'Validation Percentage for Decision Tree','type','scalar','class','real','min',15);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(TVIndex,'Start and End of the Train/Validation in Dataset','type','vector','class','real','size',[1 2],'min',0,'max',1,'issorted','ascend');
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(MinLeafSize,'Minimum relative number of leaf node observations to total samples','type','scalar','class','real','min',1e-5,'max',0.1);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Select training and validation samples
% Note: First, training samples are taken and then, validation samples are taken.  
TV = TV/sum(TV);
[ErrorMsg,TIndex,VIndex] = Partition_Dataset_ME(Dataset_ME(:,end-1:end),ClassLabels_ME,...
    {[TVIndex(1) TVIndex(1)+(TVIndex(2)-TVIndex(1))*TV(1)],...
    [TVIndex(1)+(TVIndex(2)-TVIndex(1))*TV(1) TVIndex(2)]},PartitionGenerateError);
if ~isempty(ErrorMsg)
    return;
end

%% Assignments
Dataset = Dataset_ME;
FeatureLabels = FeatureLabels_ME;
ClassLabels = ClassLabels_ME;

%% Assign Weights to Samples
Weights = Assign_Weights_ME(Dataset(:,end-1),ClassLabels,Weighting_Method);

%% Build Decision Machine
progressbar_ME('Training Decision Tree');
[Tree,~,Pc,~,~,~,stopbar] = Build_DecisionTree_ME(Dataset,ClassLabels,FeatureLabels,Weights,TIndex,VIndex,MinLeafSize,1);
if stopbar
    ErrorMsg = 'Process is aborted by user.';
    return;
end

%% Select Features based on Node Size
[UsedFeatures,idx] = unique(Tree.CutPredictor);
NodeSize = Tree.NodeSize(idx);
keep_idx = ~cellfun(@isempty,UsedFeatures);
UsedFeatures = UsedFeatures(keep_idx);
NodeSize = NodeSize(keep_idx)/Tree.NumObservations;
[NodeSize,idx] = sort(NodeSize,'descend');
UsedFeatures = UsedFeatures(idx);

%% Display Overall characteristics of the final pruned tree
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
GUI_MainEditBox_Update_ME(false,sprintf('Total features in the final pruned tree: %d from %d.',length(UsedFeatures),length(FeatureLabels)));
GUI_MainEditBox_Update_ME(false,sprintf('Average accuracy of the final pruned tree: %0.2f%%.',Pc));
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');

%% Prompt User for Selecting Features
UsedFeatures_Str = cell(1,length(UsedFeatures));
for j=1:length(UsedFeatures)
    UsedFeatures_Str{j} = sprintf('Feature #%d: %s (Relative Node Size %0.2f)',j,UsedFeatures{j},NodeSize(j));
end

[ErrorMsg,FeatureSel,~] = Select_from_List_ME(UsedFeatures_Str,1,'Select features to be included');
if ~isempty(ErrorMsg)
    return;
end
FeatureSel = FeatureSel{1};
UsedFeatures = UsedFeatures(FeatureSel);

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
