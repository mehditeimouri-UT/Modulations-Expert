function ErrorMsg = Script_AMR_ME

% This function takes iq_information_ME and does the following process:
%   - Extracts the features of iq_information_ME according to DecisionMachine_ME/DecisionMachine_CL_ME.
%   - Determines the modulation type using DecisionMachine_ME/DecisionMachine_CL_ME.
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
% 2020-Sep-26   function was created
% 2021-Jan-15   The Nodes output in decision tree was removed for 
%               compatibility with other MATLAB releases.

%% Initialization 
global DecisionMachine_ME DecisionMachine_CL_ME
global DM_ClassLabels_ME DM_FeatureLabels_ME
global DM_TrainingParameters_ME
global iq_information_ME
global DM_Function_Handles_ME DM_Function_Select_ME
global MinimumBurstLength MaximumBurstLength

%% Get Target Burst Information
N = length(iq_information_ME.Content); % Data Length
[success,BL,OL] = PromptforParameters_ME(...
    {sprintf('Bursts Length (BL=%d~%d)',MinimumBurstLength,min(N,MaximumBurstLength)),'Bursts Overlap (0~BL-1)'},...
    {num2str(min(N,MaximumBurstLength)),'0'},...
    'Fragmentation Parameters');

if ~success
    ErrorMsg = 'Parameters for Read Burst were not provided.';
    return;
end

% Check: BL is integer scalar and 1<=BL<=min(N,MaximumBurstLength)
ErrorMsg = Check_Variable_Value_ME(BL,'Bursts Length','type','scalar',...
    'class','real','class','integer','min',MinimumBurstLength,'max',min(N,MaximumBurstLength));
if ~isempty(ErrorMsg)
    return;
end

% Check: OL is integer scalar and 0<=OL<BL
ErrorMsg = Check_Variable_Value_ME(OL,'Bursts Overlap','type','scalar',...
    'class','real','class','integer','min',0,'max',BL-1);
if ~isempty(ErrorMsg)
    return;
end

%% GUI Update
GUI_MainEditBox_Update_ME(true);
GUI_MainEditBox_Update_ME(false,'Please wait ...');
pause(0.01);

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Extract Features
Function_Handles = DM_Function_Handles_ME;
Function_Select = DM_Function_Select_ME;
NumberofFeatures = sum(cell2mat(DM_Function_Select_ME));
NumberofBursts = 1+floor((N-BL)/(BL-OL));
Dataset = zeros(NumberofBursts,NumberofFeatures+2);

ptr = 0;
for BurstCnt=1:NumberofBursts
    
    x = iq_information_ME.Content(ptr+(1:BL));
    f_cnt = 0;

    for cnt = 1:length(Function_Handles)
        if any(Function_Select{cnt})
            tmp = Function_Handles{cnt}(x);
            f_sum = sum(Function_Select{cnt});
            Dataset(BurstCnt,f_cnt+(1:f_sum)) = tmp(Function_Select{cnt});
            f_cnt = f_cnt+f_sum;
        end
    end
    Dataset(BurstCnt,end-1) = 0; % Class
    Dataset(BurstCnt,end) = 0; % File Identifier
    
    % Move Pointer
    ptr = ptr+(BL-OL);
end

%% Scaling Features
switch DM_TrainingParameters_ME.Type
    case {'SVM','Ensemble kNN','Naive Bayes','Linear Discriminant Analysis (LDA)','Neural Network'}
        Dataset = Scale_Features_ME(Dataset,DM_TrainingParameters_ME.Scaling_Parameters);
        
    case {'Decision Tree','Random Forest'}

end

%% Feed Dataset to decision machine
switch DM_TrainingParameters_ME.Type
    case 'Decision Tree'
        
        [ErrorMsg,~,~,~,Scores] = ...
            Test_DecisionTree_ME(DecisionMachine_ME,Dataset,1:NumberofBursts,'',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        
    case 'SVM'
        
        [ErrorMsg,~,~,Scores,~] = ...
            Test_MultiClassSVM_ME(DecisionMachine_ME,Dataset,1:NumberofBursts,'',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        Scores(Scores<0) = 0;
        Scores = sum(Scores,1);
        S = sum(Scores);
        if S~=0
        Scores = Scores/S;
        end
        
    case 'Random Forest'
        
        [ErrorMsg,~,~,~,Scores] = Test_RandomForest_ME(DecisionMachine_CL_ME,Dataset,1:NumberofBursts,...
            '',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        
    case 'Ensemble kNN'
        
        [ErrorMsg,~,~,~,Scores] = Test_EnsemblekNN_ME(DecisionMachine_CL_ME,Dataset,1:NumberofBursts,...
            '',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        
    case 'Naive Bayes'
        
        [ErrorMsg,~,~,~,Scores] = Test_NaiveBayes_ME(DecisionMachine_ME,Dataset,1:NumberofBursts,...
            '',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        
    case 'Linear Discriminant Analysis (LDA)'
        
        [ErrorMsg,~,~,~,Scores] = Test_LDA_ME(DecisionMachine_CL_ME,Dataset,1:NumberofBursts,...
            '',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        
    case 'Neural Network'
        [ErrorMsg,~,~,~,Scores] = Test_PatternRecognitionNeuralNetwork_ME(DecisionMachine_ME,Dataset,1:NumberofBursts,...
            '',DM_ClassLabels_ME,DM_FeatureLabels_ME,DM_FeatureLabels_ME,ones(NumberofBursts,1));
        
end

if ~isempty(ErrorMsg)
    return;
end

%% display Results
Scores = mean(Scores,1);
[~,idx] = sort(Scores,'descend');
Classes = DM_ClassLabels_ME(idx);
Scores = Scores(idx);
GUI_MainEditBox_Update_ME(false,sprintf('------ AMR Result Using %d Burst ------',NumberofBursts));
for j=1:length(Scores)
    
    if Scores(j)==0
        break;
    end
    
    GUI_MainEditBox_Update_ME(false,sprintf('%s: %g%%',Classes{j},round(Scores(j)*10000)/100));
    
end
GUI_MainEditBox_Update_ME(false,'---------------------------------------');