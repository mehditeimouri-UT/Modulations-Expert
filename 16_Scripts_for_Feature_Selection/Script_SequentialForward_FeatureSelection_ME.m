function ErrorMsg = Script_SequentialForward_FeatureSelection_ME

% This function takes Dataset_ME with L rows (L samples) and C columns (C-2 features) and does the following process:
%   (1) By using a greedy search algorithm it attempts to find the “optimal” feature subset by iteratively selecting features
%       based on the LDA classifier performance.
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
TV = [100 0]; % Train/Validation Percentages
PartitionGenerateError = [true false];

Param_Names = {'Weighting_Method','TVTIndex','K','feature_scaling_method'};
Param_Description = {'Weighting Method (balanced or uniform)',...
    'Start and End of the Train/Validation/Test in Dataset (1x2 vector with elements 0~1)',...
    'K value of K-Fold Cross-Validation (>=2 and <=10)',...
    'The method of feature scaling: z-score, min-max, or  no scaling'};
Default_Value = {'balanced','[0 1]','5','z-score'};
dlg_title = 'Parameters for Sequential Forward Feature Selection with LDA';
str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title);
eval(str_cmd);

if ~success
    ErrorMsg = 'Process is aborted. Parameters are not specified for training decision machine.';
    return;
end

%% Check Parameters
ErrMsg = Check_Variable_Value_ME(Weighting_Method,'Weighting Method','possiblevalues',{'balanced','uniform'});
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(TVTIndex,'Start and End of the Train/Validation/Test in Dataset','type','vector','class','real','size',[1 2],'min',0,'max',1,'issorted','ascend');
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(K,'K value of K-Fold Cross-Validation','type','scalar','class','real','class','integer','min',2,'max',10);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(feature_scaling_method,'The method of feature scaling','possiblevalues',{'z-score','min-max','no scaling'});
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

%% Get Filename for saving the final dataset
[Filename,path] = uiputfile('feature_selected_dataset.mat','Save Feature-Selected Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% K-Fold Partitioning
idx = TVTIndex(1)+(TVTIndex(2)-TVTIndex(1))*(0:1/K:1);
[ErrorMsg,KFoldsIdx] = Partition_Dataset_ME(Dataset_ME(:,end-1:end),ClassLabels_ME,{idx});
if ~isempty(ErrorMsg)
    return;
end

TV = TV/sum(TV);
TV = cumsum([0 TV]);

AllIndex = [];
for j=1:K
    AllIndex = union(AllIndex,KFoldsIdx{j});
end

%% Assign Weights
Weights = Assign_Weights_ME(Dataset_ME(:,end-1),ClassLabels_ME,Weighting_Method);

%% Greedy Search Loop
AllFeatures = (1:size(Dataset_ME,2)-2);
SelectedFeatures = [];
Pc_Selected = zeros(1,size(Dataset_ME,2)-1);
cnt = 1;
while(~isempty(AllFeatures))
    
    % Initialize
    progressbar_ME(sprintf('Selecting feature #%d',length(SelectedFeatures)+1),'Loop over K Folds');
    
    Pc = zeros(1,size(Dataset_ME,2)-2);
    for i=1:length(AllFeatures) % Loop over features
        
        % Feature Vector
        Features = [SelectedFeatures AllFeatures(i)];
        
        for j=1:K % Loop over K Folds
            
            % Train and Test Index
            TestIndex = KFoldsIdx{j};
            TrainValidationIndex = setdiff(AllIndex,TestIndex);
            [ErrorMsg,TIndex,VIndex] = Partition_Dataset_ME(Dataset_ME(TrainValidationIndex,end-1:end),ClassLabels_ME,{[TV(1) TV(2)],[TV(2) TV(3)]},PartitionGenerateError);
            if ~isempty(ErrorMsg)
                progressbar_ME(1,1);
                return;
            end
            
            % Scaling Features
            Dataset = zeros(size(Dataset_ME,1),length(Features)+2);
            [Dataset(TrainValidationIndex,:),Scaling_Parameters] = Scale_Features_ME(Dataset_ME(TrainValidationIndex,[Features end-1:end]),feature_scaling_method);
            Dataset(TestIndex,:) = Scale_Features_ME(Dataset_ME(TestIndex,[Features end-1:end]),Scaling_Parameters);
            
            % Train Decision Model
            [DM,~,~,~,~] = Build_LDA_ME(Dataset,ClassLabels_ME,FeatureLabels_ME(Features),Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex));
            
            % Evaluate the performance of the final decision machine on the test set
            [~,Pc_tmp,~,~,~] = Test_LDA_ME(DM,Dataset,TestIndex,...
                ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME(Features),FeatureLabels_ME(Features),Weights);
            
            % Update Test Results
            Pc(i)= Pc(i)+Pc_tmp;
            
            % progress indication
            stopbar = progressbar_ME(2,j/K);
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
            
        end
        
        % Update Test Results
        Pc(i) = Pc(i)/K;

        % progress indication
        stopbar = progressbar_ME(1,i/length(AllFeatures));
        if stopbar
            ErrorMsg = 'Process is aborted by user.';
            return;
        end
        
    end
    
    % Add Feature
    cnt = cnt+1;
    [maxval,maxidx] = max(Pc);
    Pc_Selected(cnt) = maxval;
    
    % No improvement
    if Pc_Selected(cnt)<=Pc_Selected(cnt-1)
        GUI_MainEditBox_Update_ME(false,'No improvement is seen. Process of feature selection is stopped.');
        break;
    end
    
    GUI_MainEditBox_Update_ME(false,sprintf('Selected feature #%d is %s. Average accuracy is %0.2f%%.',...
        cnt-1,FeatureLabels_ME{AllFeatures(maxidx)},Pc_Selected(cnt)));
    SelectedFeatures = [SelectedFeatures AllFeatures(maxidx)];
    AllFeatures = setdiff(AllFeatures,AllFeatures(maxidx));
    
end

if isempty(AllFeatures)
    GUI_MainEditBox_Update_ME(false,'All Features are needed. There is no need for saving the results.');
    return;
end

%% Select Sub-Features
FeatSel = sort(SelectedFeatures);
Dataset = Dataset_ME(:,[FeatSel end-1:end]);
FeatureLabels = FeatureLabels_ME(FeatSel);

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
ClassLabels = ClassLabels_ME;
Function_Handles = Function_Handles_ME;
Function_Labels = Function_Labels_ME;
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_ME(false,'The process is completed successfully.');