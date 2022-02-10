function [ErrorMsg,MergedDataset,MergedClassLabels] = MergeLabels_Dataset_ME(Dataset,ClassLabels)

% This function takes labels of a Dataset and merge groups of labels into new labels.
% Merged groups are selected by a graphical user interface.
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
% Inputs:
%   Dataset: Dataset with L rows (L samples corresponding to L bursts)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   ClassLabels: 1xN cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%   MergedDataset: Dataset with L rows (L samples) and C columns (C-1 features)
%       and final column is the integer-valued class label (an integer).
%   MergedClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%
%   Note: In Dataset and MergedDataset, First, the samples of class 1 appear.
%   Second, the the samples of class 2 appear, and so on. Also, for the samples
%   of each class, the bursts with similar file identifier appear consecutively.
%
% Revisions:
% 2020-Sep-23   function was created

%% Initialization
ErrorMsg = '';
MergedDataset = [];
MergedClassLabels = {};

%% Select Labels to Merge
[~,MergedClassIndices,Remain] = Select_from_List_ME(ClassLabels,inf,'Select labels to merge');
MergedClassIndices = [MergedClassIndices num2cell(Remain)];

if length(MergedClassIndices)==length(ClassLabels)
    ErrorMsg = 'Process is aborted. In fact, no merging was applied and all old classes are kept.';
    return;
end

MergedClassLabels = SetVariableNames_ME(Select_CellContents_ME(ClassLabels,MergedClassIndices),true);

%% Re-Generate Dataset
M = length(MergedClassLabels);
MergedDataset = Dataset;
for j=1:M
    for i=1:length(MergedClassIndices{j})
        idx = (Dataset(:,end-1)==MergedClassIndices{j}(i));
        MergedDataset(idx,end-1) = j;
    end
end

%% Sort Labels
[~,idx] = sort(MergedDataset(:,end-1));
MergedDataset = MergedDataset(idx,:);

%% Sort File Identifiers
for j=1:M
    idx = find(MergedDataset(:,end-1)==j); % Indices for Class j
    FileID = MergedDataset(idx,end); % File Identifiers for Class j Samples
    [~,idx0] = sort(FileID);
    
    MergedDataset(idx,:) = MergedDataset(idx(idx0),:);
end