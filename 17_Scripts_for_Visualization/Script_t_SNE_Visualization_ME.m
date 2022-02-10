function ErrorMsg = Script_t_SNE_Visualization_ME

% This function takes Dataset_ME with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Visualize data samples in 2-D or 3-D feature space using t-SNE. 
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
% 2020-Nov-12   function was created

%% Initialization
global ClassLabels_ME Dataset_ME

if isempty(Dataset_ME)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

if (size(Dataset_ME,2)-2)<4
    ErrorMsg = 'The dataset should contain at least 4 features.';
    return;
end

if length(ClassLabels_ME)<2
    ErrorMsg = 'At least two classes should be presented.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Select Classses
[ErrorMsg,ClassIdx,~] = Select_from_List_ME(ClassLabels_ME,inf,'Select class labels');
if ~isempty(ErrorMsg)
    return;
end

CategoriesLabels = SetVariableNames_ME(Select_CellContents_ME(ClassLabels_ME,ClassIdx),false);

%% Get Parameters
no_dims = 2; % Final Reduced Dimensionality (2 or 3)
initial_dims = min(size(Dataset_ME,2)-2,50); % Initial Reduced Dimensionality 
perplexity = 15; % The perplexity of the Gaussian kernel (2~50)
max_iter = 1000; % Maximum number of iterations (100~1000)

[success,no_dims,initial_dims,perplexity,max_iter] = PromptforParameters_ME(...
    {'Final Reduced Dimensionality (2 or 3)',...
    sprintf('Initial Reduced Dimensionality (4~%d)',size(Dataset_ME,2)-2),...
    'The perplexity of the Gaussian kernel (2~50)',...
    'Maximum number of iterations (100~1000)'},...
    {num2str(no_dims),num2str(initial_dims),num2str(perplexity),num2str(max_iter)},'Parameters for t-SNE');

if ~success
    ErrorMsg = 'Process is aborted. Parameters for t-SNE are not specified.';
    return;
end

%% Check Parameters
ErrMsg = Check_Variable_Value_ME(no_dims,'Final Reduced Dimensionality','type','scalar','class','real','class','integer','min',2,'max',3);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(initial_dims,'Initial Reduced Dimensionality','type','scalar','class','real','class','integer','min',4,'max',size(Dataset_ME,2)-2);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(perplexity,'The perplexity of the Gaussian kernel','type','scalar','class','real','class','integer','min',2,'max',50);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

ErrMsg = Check_Variable_Value_ME(max_iter,'Maximum number of iterations','type','scalar','class','real','class','integer','min',100,'max',1000);
if ~isempty(ErrMsg)
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

%% Select Classes in Dataset
Dataset = Dataset_ME;
fun = cell(1,length(ClassIdx));
Dataset(:,end) = 0;
for j=1:length(ClassIdx)
    
    % Find rows for class j
    fun{j} = @(x) ismember(x,ClassIdx{j});
    idx = arrayfun(fun{j},Dataset(:,end-1));
    Dataset(idx,end) = j;
    
end
Dataset(Dataset(:,end)==0,:) = [];
Dataset(:,end-1) = Dataset(:,end);

%% Run t-SNE
ydata = tsne_ME(Dataset(:,1:end-2),CategoriesLabels(Dataset(:,end-1))',no_dims,initial_dims,perplexity,max_iter);
if isequal(ydata,-1)
    ErrorMsg = 'Process is aborted by user.';
    return;
end
%% Update GUI
GUI_MainEditBox_Update_ME(false,'Visualization is completed.');