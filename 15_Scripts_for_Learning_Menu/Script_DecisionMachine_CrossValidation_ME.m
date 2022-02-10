function ErrorMsg = Script_DecisionMachine_CrossValidation_ME

% This function takes Dataset_ME with L rows (L samples) and C columns (C-2 features) and does the following process:
%   (1) Random permuting samples in order to shuffle samples (if indicated by RandomShuffle input)
%   (2) Cross-Validate the performance of decesion-machine in prediction the
%   label for Dataset_ME samples.
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
% 2021-Jan-15   The Nodes output in decision tree was removed for 
%               compatibility with other MATLAB releases.

%% Initialization
global Dataset_ME
global ClassLabels_ME
global FeatureLabels_ME
global Dataset_ME_Name_TextBox

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

%% Determine Decision Machine Type
DecisionModels = {'Decision Tree','SVM','Random Forest','Ensemble kNN','Naive Bayes','Linear Discriminant Analysis (LDA)','Neural Network'};
[ErrorMsg,Subsets] = Select_from_List_ME(DecisionModels,1,'Select Decision Model',true);
if ~isempty(ErrorMsg)
    return;
end
DecisionModel = DecisionModels{Subsets{1}};

%% Parameters
Param_Names = {'Weighting_Method','TVTIndex','K','TV'};
Param_Description = {'Weighting Method (balanced or uniform)',...
    'Start and End of the Train/Validation/Test in Dataset (1x2 vector with elements 0~1)',...
    'K value of K-Fold Cross-Validation (>=2 and <=10)',...
    'Train and Validation Percentages (1x2 vector with sum ==100, Train>=70, and for Decision Tree and Neural Network, Validation>=15)'};
if isequal(DecisionModel,'Decision Tree') || isequal(DecisionModel,'Neural Network')
    Default_Value = {'balanced','[0 1]','5','[80 20]'};
else
    Default_Value = {'balanced','[0 1]','5','[100 0]'};
end

switch DecisionModel
    case 'Decision Tree'
        Param_Names = [Param_Names 'MinLeafSize_Values'];
        Param_Description = [Param_Description 'Different values for minimum relative number of leaf node observations to total samples (1e-5~0.1)'];
        Default_Value = [Default_Value '(0.001:0.001:0.01)'];
        
    case 'SVM'
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or  no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
        Param_Names = [Param_Names 'KernelFunction'];
        Param_Description = [Param_Description 'Kernel Function for SVM: rbf, linear, polynomial'];
        Default_Value = [Default_Value 'rbf'];
        
        Param_Names = [Param_Names 'PolynomialOrder'];
        Param_Description = [Param_Description 'Polynomial order for polynomial kernel function (1~7)'];
        Default_Value = [Default_Value '3'];
        
        Param_Names = [Param_Names 'BoxConstraint_values'];
        Param_Description = [Param_Description 'Different values for box constraint in SVM (>0)'];
        Default_Value = [Default_Value '(0.5:0.5:1.5)'];
        
        Param_Names = [Param_Names 'KernelScale_values'];
        Param_Description = [Param_Description 'Different values for scaling kernel of SVM (>0)'];
        Default_Value = [Default_Value '(0.1:0.3:1)'];
        
    case 'Random Forest'
        Param_Names = [Param_Names 'NumTrees_Values'];
        Param_Description = [Param_Description 'Different values for number of trees in random forest (2~1e4)'];
        Default_Value = [Default_Value '(10:10:50)'];
        
        Param_Names = [Param_Names 'MinLeafSize_Values'];
        Param_Description = [Param_Description 'Different values for minimum relative number of leaf node observations to total samples (1e-5~0.1)'];
        Default_Value = [Default_Value '(0.0001:0.0001:0.001)'];
        
    case 'Ensemble kNN'
        
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or  no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
        Param_Names = [Param_Names 'NumFeatures'];
        Param_Description = [Param_Description sprintf('Number of random selected features for each kNN learner (<=%d)',length(FeatureLabels_ME))];
        Default_Value = [Default_Value num2str(min(length(FeatureLabels_ME),6))];
        
        Param_Names = [Param_Names 'NumLearners_Values'];
        Param_Description = [Param_Description 'Different values for number of kNN learners in ensemble (1~1e4)'];
        Default_Value = [Default_Value '[10:10:100]'];
        
        Param_Names = [Param_Names 'NumNeighbors_Values'];
        Param_Description = [Param_Description 'Different values for number of nearest neighbors for classifying each point (1~50)'];
        Default_Value = [Default_Value '(1:2:7)'];
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or  no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
    case 'Neural Network'
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or  no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
        Param_Names = [Param_Names 'hiddenSize_Values'];
        Param_Description = [Param_Description sprintf('Different values for dimension of hidden layer (<=%d)',length(FeatureLabels_ME))];
        Default_Value = [Default_Value ['1:' num2str(length(FeatureLabels_ME))]];
        
end
dlg_title = sprintf('Parameters for Cross-Validation of %s',DecisionModel);
str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title);
eval(str_cmd);


if ~success
    ErrorMsg = 'Process is aborted. Parameters are not specified for training decision machine.';
    return;
end

%% Check Parameters
ErrorMsg = Check_Variable_Value_ME(Weighting_Method,'Weighting Method','possiblevalues',{'balanced','uniform'});
if ~isempty(ErrorMsg)
    return;
end

ErrorMsg = Check_Variable_Value_ME(TVTIndex,'Start and End of the Train/Validation/Test in Dataset','type','vector','class','real','size',[1 2],'min',0,'max',1,'issorted','ascend');
if ~isempty(ErrorMsg)
    return;
end

ErrorMsg = Check_Variable_Value_ME(K,'K value of K-Fold Cross-Validation','type','scalar','class','real','class','integer','min',2,'max',10);
if ~isempty(ErrorMsg)
    return;
end

ErrorMsg = Check_Variable_Value_ME(TV,'Train and Validation Percentages','type','vector','class','real','size',[1 2],'sum',100,'min',0);
if ~isempty(ErrorMsg)
    return;
end

ErrorMsg = Check_Variable_Value_ME(TV(1),'Train Percentage','type','scalar','class','real','min',70);
if ~isempty(ErrorMsg)
    return;
end

if isequal(DecisionModel,'Decision Tree') || isequal(DecisionModel,'Neural Network')
    PartitionGenerateError = [true true];
    ErrorMsg = Check_Variable_Value_ME(TV(2),sprintf('Validation Percentage for %s',DecisionModel),'type','scalar','class','real','min',15);
    if ~isempty(ErrorMsg)
        return;
    end
else
    PartitionGenerateError = [true false];
end


if isequal(exist('MinLeafSize_Values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(MinLeafSize_Values,'Minimum relative number of leaf node observations to total samples','type','vector','class','real','min',1e-5,'max',0.1);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('feature_scaling_method','var'),1)
    ErrorMsg = Check_Variable_Value_ME(feature_scaling_method,'The method of feature scaling','possiblevalues',{'z-score','min-max','no scaling'});
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('KernelFunction','var'),1)
    ErrorMsg = Check_Variable_Value_ME(KernelFunction,'The kernel function','possiblevalues',{'rbf','linear','polynomial'});
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('PolynomialOrder','var'),1)
    ErrorMsg = Check_Variable_Value_ME(PolynomialOrder,'The polynomial order for polynomial kernel function','type','scalar','class','real','class','integer','min',1,'max',7);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('BoxConstraint_values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(BoxConstraint_values,'Box constraint in SVM','type','vector','class','real','min',eps);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('KernelScale_values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(KernelScale_values,'Kernel scale factor of SVM','type','vector','class','real','min',eps);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('NumTrees_Values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(NumTrees_Values,'Number of trees in random forest','type','vector','class','real','class','integer','min',2,'max',1e4);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('NumFeatures','var'),1)
    ErrorMsg = Check_Variable_Value_ME(NumFeatures,'Number of random selected features for each kNN learner','type','scalar','class','real','class','integer','min',1,'max',length(FeatureLabels_ME));
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('NumLearners_Values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(NumLearners_Values,'Number of kNN learners in ensemble','type','vector','class','real','class','integer','min',1,'max',1e4);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('NumNeighbors_Values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(NumNeighbors_Values,'Number of nearest neighbors for classifying each point','type','vector','class','real','class','integer','min',1,'max',50);
    if ~isempty(ErrorMsg)
        return;
    end
end

if isequal(exist('hiddenSize_Values','var'),1)
    ErrorMsg = Check_Variable_Value_ME(hiddenSize_Values,'Dimension of hidden layer','type','vector','class','real','class','integer','min',1,'max',length(FeatureLabels_ME));
    if ~isempty(ErrorMsg)
        return;
    end
end

%% Get File Name for Saving the Results
FullFileName = ['CrossValidation_' matlab.lang.makeValidName(DecisionModel) '.mat'];
if FullFileName(end-4)=='_'
    FullFileName(end-4) = [];
end
[Filename,path] = uiputfile('*.mat','Save Cross-Validation Results As',FullFileName);
FullFileName = [path Filename];
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving the cross-validation results.';
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

%% Assign Weights
Weights = Assign_Weights_ME(Dataset_ME(:,end-1),ClassLabels_ME,Weighting_Method);

%% Initialize Progressbar
switch DecisionModel
    case 'Decision Tree'
        progressbar_ME('Loop over Tuning Parameter','Loop over K Folds','Training Decision Tree');
        
    case 'SVM'
        progressbar_ME('Loop over Tuning Parameters','Loop over K Folds','Training Multi-Class SVM Model');
        
    case {'Random Forest','Ensemble kNN','Neural Network'}
        progressbar_ME('Loop over Tuning Parameters','Loop over K Folds');
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        progressbar_ME('Loop over K Folds');
        
end

%% Prepare Tuning Parameter
switch DecisionModel
    case 'Decision Tree'
        L_Tune = length(MinLeafSize_Values);
        
    case 'SVM'
        [S_values,C_values] = meshgrid(KernelScale_values,BoxConstraint_values);
        L_Tune = numel(S_values);
        
    case 'Random Forest'
        [NT_values,MLS_values] = meshgrid(sort(NumTrees_Values),MinLeafSize_Values);
        L_Tune = numel(NT_values);
        
        DM = cell(size(NT_values,1),size(NT_values,2),K); % Initial Random Forests
        Trees_Total = sum(sum(diff([zeros(size(NT_values,1),1) NT_values],1,2))); % Total Number of Trees for each fold
        Trees_Cnt = 0;
        
    case 'Ensemble kNN'
        [NL_values,NN_values] = meshgrid(sort(NumLearners_Values),NumNeighbors_Values);
        L_Tune = numel(NL_values);
        
        DM = cell(size(NL_values,1),size(NL_values,2),K); % Initial kNNs
        kNNs_Total = sum(sum(diff([zeros(size(NL_values,1),1) NL_values],1,2))); % Total Number of Trees for each fold
        kNNs_Cnt = 0;
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        L_Tune = 1;
        
    case 'Neural Network'
        L_Tune = length(hiddenSize_Values);
        
end

%% K-Fold Cross-Validation
AllIndex = [];
for j=1:K
    AllIndex = union(AllIndex,KFoldsIdx{j});
end

M = length(ClassLabels_ME);

% Predicted Labels and Scores for all data over various tuning parameters
PredictedLabels_Tune = repmat({zeros(size(Dataset_ME,1),1)},1,L_Tune);
Scores_Tune = repmat({zeros(size(Dataset_ME,1),length(ClassLabels_ME))},1,L_Tune);

% Confusion matrices and accuracy for training data over various tuning parameters
ConfusionMatrix_Train_Tune = repmat({zeros(M,M)},1,L_Tune);
Pc_Train_Tune = repmat({0},1,L_Tune);

% Confusion matrices and accuracy for validation data over various tuning parameters
ConfusionMatrix_Validation_Tune = repmat({zeros(M,M)},1,L_Tune);
Pc_Validation_Tune = repmat({0},1,L_Tune);

% Confusion matrices and accuracy for test data over various tuning parameters
ConfusionMatrix_Tune = repmat({zeros(M,M)},1,L_Tune);
Pc_Tune = repmat({0},1,L_Tune);

for i=1:L_Tune % Loop over Tuning Parameter
    
    % progress indication
    switch DecisionModel
        case {'Decision Tree','SVM','Random Forest','Ensemble kNN','Neural Network'}
            stopbar = progressbar_ME(2,eps);
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
            
        case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
            
    end
    
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
        Dataset = Dataset_ME;
        switch DecisionModel
            case {'SVM','Ensemble kNN','Naive Bayes','Linear Discriminant Analysis (LDA)','Neural Network'}
                [Dataset(TrainValidationIndex,:),Scaling_Parameters] = Scale_Features_ME(Dataset_ME(TrainValidationIndex,:),feature_scaling_method);
                Dataset(TestIndex,:) = Scale_Features_ME(Dataset_ME(TestIndex,:),Scaling_Parameters);
                
            case {'Decision Tree','Random Forest'}
                
        end
        
        % Train Decision Model
        switch DecisionModel
            case 'Decision Tree'
                
                % Build Decision Trees
                [DM,~,Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp,stopbar] = ...
                    Build_DecisionTree_ME(Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex),MinLeafSize_Values(i),3);
                if stopbar
                    ErrorMsg = 'Process is aborted by user.';
                    return;
                end
                
            case 'SVM'
                
                % Build SVM Model
                [DM,~,Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp,~,~,~,~,stopbar] = ...
                    Build_MultiClassSVM_ME(Dataset,ClassLabels_ME,FeatureLabels_ME,...
                    Weights,Weighting_Method,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex),...
                    KernelFunction,PolynomialOrder,S_values(i),C_values(i),3);
                if stopbar
                    ErrorMsg = 'Process is aborted by user.';
                    return;
                end
                
            case 'Random Forest'
                
                % Build Random Forest
                [I_idx,J_idx] = ind2sub(size(NT_values),i);
                
                if J_idx==1 % Train Initial Random Forest
                    [DM{I_idx,J_idx,j},Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = ...
                        Build_RandomForest_ME([],Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex),...
                        NT_values(i),MLS_values(i));
                    
                    Trees_Cnt = Trees_Cnt+(j==1)*NT_values(i);
                    
                else % Train Additional Trees
                    [DM{I_idx,J_idx,j},Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = Build_RandomForest_ME(DM{I_idx,J_idx-1,j},Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex),...
                        NT_values(I_idx,J_idx)-NT_values(I_idx,J_idx-1),MLS_values(i));
                    
                    Trees_Cnt = Trees_Cnt+(j==1)*(NT_values(I_idx,J_idx)-NT_values(I_idx,J_idx-1));
                end
                
            case 'Ensemble kNN'
                
                [I_idx,J_idx] = ind2sub(size(NL_values),i);
                
                % Build kNN Model
                if J_idx==1 % Train Initial ensemble kNN
                    [DM{I_idx,J_idx,j},Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = Build_EnsemblekNN_ME([],Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex),...
                        NL_values(i),NumFeatures,NN_values(i));
                    
                    kNNs_Cnt = kNNs_Cnt+(j==1)*NL_values(i);
                    
                else % Train Additional kNNs
                    [DM{I_idx,J_idx,j},Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = Build_EnsemblekNN_ME(DM{I_idx,J_idx,j},Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex),...
                        NL_values(I_idx,J_idx)-NL_values(I_idx,J_idx-1),NumFeatures,NN_values(i));
                    
                    kNNs_Cnt = kNNs_Cnt+(j==1)*(NL_values(I_idx,J_idx)-NL_values(I_idx,J_idx-1));
                end
                
            case 'Naive Bayes'
                [DM,~,Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = Build_NaiveBayes_ME(Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex));
                
            case 'Linear Discriminant Analysis (LDA)'
                [DM,Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = Build_LDA_ME(Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex),TrainValidationIndex(VIndex));
                
            case 'Neural Network'
                [DM,Pc_tmp,ConfusionMatrix_tmp,Pc_Train_tmp,ConfusionMatrix_Train_tmp] = Build_PatternRecognitionNeuralNetwork_ME(Dataset,ClassLabels_ME,FeatureLabels_ME,Weights,TrainValidationIndex(TIndex)',TrainValidationIndex(VIndex)',hiddenSize_Values(i));
        end
        
        % Update Training Results
        ConfusionMatrix_Train_Tune{i} = ConfusionMatrix_Train_Tune{i}+Scale_ConfusionMatrix_ME(ConfusionMatrix_Train_tmp);
        Pc_Train_Tune{i} = Pc_Train_Tune{i}+Pc_Train_tmp;
        
        % Update Validation Results
        ConfusionMatrix_Validation_Tune{i} = ConfusionMatrix_Validation_Tune{i}+Scale_ConfusionMatrix_ME(ConfusionMatrix_tmp);
        Pc_Validation_Tune{i} = Pc_Validation_Tune{i}+Pc_tmp;
        
        % Evaluate the performance of the final decision machine on the test set
        switch DecisionModel
            case 'Decision Tree'
                
                % Test Decision Tree
                [~,Pc_tmp,ConfusionMatrix_tmp,PLabel_tmp,Sc_tmp] = Test_DecisionTree_ME(DM,Dataset,TestIndex,ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
                
            case 'SVM'
                
                % Test SVM Model
                [~,Pc_tmp,ConfusionMatrix_tmp,Sc_tmp,PLabel_tmp] = ...
                    Test_MultiClassSVM_ME(DM,Dataset,TestIndex,ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
                
            case 'Random Forest'
                
                % Test Random Forest
                [~,Pc_tmp,ConfusionMatrix_tmp,PLabel_tmp,Sc_tmp] = Test_RandomForest_ME(DM{I_idx,J_idx,j},Dataset,TestIndex,...
                    ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
                
            case 'Ensemble kNN'
                
                % Test Ensemble SVM
                [~,Pc_tmp,ConfusionMatrix_tmp,PLabel_tmp,Sc_tmp] = Test_EnsemblekNN_ME(DM{I_idx,J_idx,j},Dataset,TestIndex,...
                    ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
                
            case 'Naive Bayes'
                [~,Pc_tmp,ConfusionMatrix_tmp,PLabel_tmp,Sc_tmp] = Test_NaiveBayes_ME(DM,Dataset,TestIndex,...
                    ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
                
            case 'Linear Discriminant Analysis (LDA)'
                [~,Pc_tmp,ConfusionMatrix_tmp,PLabel_tmp,Sc_tmp] = Test_LDA_ME(DM,Dataset,TestIndex,...
                    ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
                
            case 'Neural Network'
                [~,Pc_tmp,ConfusionMatrix_tmp,PLabel_tmp,Sc_tmp] = Test_PatternRecognitionNeuralNetwork_ME(DM,Dataset,TestIndex,...
                    ClassLabels_ME,ClassLabels_ME,FeatureLabels_ME,FeatureLabels_ME,Weights);
        end
        
        
        % Update Test Results
        ConfusionMatrix_Tune{i} = ConfusionMatrix_Tune{i}+Scale_ConfusionMatrix_ME(ConfusionMatrix_tmp);
        Pc_Tune{i} = Pc_Tune{i}+Pc_tmp;
        PredictedLabels_Tune{i}(TestIndex) = PLabel_tmp;
        Scores_Tune{i}(TestIndex,:) = Sc_tmp;
        
        % progress indication
        switch DecisionModel
            case {'Decision Tree','SVM','Random Forest','Ensemble kNN','Neural Network'}
                stopbar = progressbar_ME(2,j/K);
                if stopbar
                    ErrorMsg = 'Process is aborted by user.';
                    return;
                end
                
            case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
                stopbar = progressbar_ME(1,j/K);
                if stopbar
                    ErrorMsg = 'Process is aborted by user.';
                    return;
                end
        end
        
    end
    
    % Update Training, Validtion and Test Results
    ConfusionMatrix_Train_Tune{i} = ConfusionMatrix_Train_Tune{i}/K;
    Pc_Train_Tune{i} = Pc_Train_Tune{i}/K;
    ConfusionMatrix_Validation_Tune{i} = ConfusionMatrix_Validation_Tune{i}/K;
    Pc_Validation_Tune{i} = Pc_Validation_Tune{i}/K;
    ConfusionMatrix_Tune{i} = ConfusionMatrix_Tune{i}/K;
    Pc_Tune{i} = Pc_Tune{i}/K;
    
    % progress indication
    switch DecisionModel
        
        case 'Random Forest'
            stopbar = progressbar_ME(1,Trees_Cnt/Trees_Total);
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
            
        case 'Ensemble kNN'
            stopbar = progressbar_ME(1,kNNs_Cnt/kNNs_Total);
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
            
        case {'Decision Tree','SVM','Neural Network'}
            stopbar = progressbar_ME(1,i/L_Tune);
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
            
        case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
            
    end
    
end

%% Find the best tuning parameter and set corresponding cross-validation result
[Pc,idx] = max(cell2mat(Pc_Tune));
ConfusionMatrix = ConfusionMatrix_Tune{idx};

ConfusionMatrix_Train = ConfusionMatrix_Train_Tune{idx};
Pc_Train = Pc_Train_Tune{idx};

ConfusionMatrix_Validation = ConfusionMatrix_Validation_Tune{idx};
Pc_Validation = Pc_Validation_Tune{idx};

PredictedLabels = PredictedLabels_Tune{idx};
Scores = Scores_Tune{idx};

%% Set Variables for Cross-Validation Results

% Cross-Validation Parameters
CV_Parameters.DM_Type = DecisionModel;
CV_Parameters.Dataset_FileName = get(Dataset_ME_Name_TextBox,'String'); % The name of the employed Dataset
CV_Parameters.Dataset_ClassLabels = ClassLabels_ME;

CV_Parameters.Weighting_Method = Weighting_Method;
CV_Parameters.TVTIndex = TVTIndex;
CV_Parameters.K = K;
CV_Parameters.TV = diff(TV);

% Cross-Validation Results
CV_Results.Pc_Train_Tune = Pc_Train_Tune;
CV_Results.ConfusionMatrix_Train_Tune = ConfusionMatrix_Train_Tune;
CV_Results.Pc_Validation_Tune = Pc_Validation_Tune;
CV_Results.ConfusionMatrix_Validation_Tune = ConfusionMatrix_Validation_Tune;
CV_Results.Pc_Tune = Pc_Tune;
CV_Results.ConfusionMatrix_Tune = ConfusionMatrix_Tune;
CV_Results.PredictedLabels_Tune = PredictedLabels_Tune;
CV_Results.Scores_Tune = Scores_Tune;

% Cross-Validation Best Results
CV_Results.Pc_Train = Pc_Train;
CV_Results.ConfusionMatrix_Train = ConfusionMatrix_Train;
CV_Results.Pc_Validation = Pc_Validation;
CV_Results.ConfusionMatrix_Validation = ConfusionMatrix_Validation;
CV_Results.Pc = Pc;
CV_Results.ConfusionMatrix = ConfusionMatrix;
CV_Results.TrueLabels = Dataset_ME(:,end-1);
CV_Results.PredictedLabels = PredictedLabels;
CV_Results.Scores = Scores;

switch DecisionModel
    case 'Decision Tree'
        CV_Parameters.MinLeafSize = MinLeafSize_Values;
        CV_Results.BestMinLeafSize = MinLeafSize_Values(idx);
        
    case 'SVM'
        CV_Parameters.KernelFunction = KernelFunction;
        CV_Parameters.PolynomialOrder = PolynomialOrder;
        CV_Parameters.feature_scaling_method = feature_scaling_method;
        CV_Parameters.BoxConstraint_MeshGrid = C_values;
        CV_Parameters.KernelScale_MeshGrid = S_values;
        CV_Parameters.BestKernelScale = S_values(idx);
        CV_Results.BestBoxConstraint = C_values(idx);
        
    case 'Random Forest'
        CV_Parameters.NumTrees_MeshGrid = NT_values;
        CV_Parameters.MinLeafSize_MeshGrid = MLS_values;
        CV_Results.BestNumTrees = NT_values(idx);
        CV_Results.BestMinLeafSize = MLS_values(idx);
        
    case 'Ensemble kNN'
        CV_Parameters.feature_scaling_method = feature_scaling_method;
        CV_Parameters.NumFeatures = NumFeatures;
        CV_Parameters.NumLearners_MeshGrid = NL_values;
        CV_Parameters.NumNeighbors_MeshGrid = NN_values;
        CV_Results.BestNumLearners = NL_values(idx);
        CV_Results.BestNumNeighbors = NN_values(idx);
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        CV_Parameters.feature_scaling_method = feature_scaling_method;
        
    case 'Neural Network'
        CV_Parameters.feature_scaling_method = feature_scaling_method;
        CV_Parameters.hiddenSize_Values = hiddenSize_Values;
        CV_Results.BesthiddenSize = hiddenSize_Values(idx);
        
end

%% Show Cross-Validation Results
Display_CrossValidationResults_ME(CV_Parameters,CV_Results);

%% Save Cross-Validation Results
save(FullFileName,'CV_Parameters','CV_Results','-v7.3');

%% Update GUI
GUI_CrossValidationResults_Update_ME(Filename,CV_Parameters,CV_Results);
GUI_MainEditBox_Update_ME(false,'The process is completed successfully.');