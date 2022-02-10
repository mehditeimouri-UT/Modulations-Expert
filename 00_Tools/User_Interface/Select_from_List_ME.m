function [ErrorMsg,Subsets,Idx] = Select_from_List_ME(Labels,NumSubSets,prompt,single_select)

% This function gets a list and selects one or more non-overlapping subsets
% from this list. The output is the subsets containing the indices of the selected elements. 
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
%   Labels: A 1xN string cell that denote the elements of the list.
%   NumSubSets: Maximum number of subsets that should be selected.
%   dlg_title: A string array that represents the prompt string of dialog box.
%   single_select (optional, with default = false): If true, only single-selection is allowed in each step.
%
% Output:
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty. 
%   Subsets: A cell array, in which, each element denotes the
%       indices of the elements of corresponding subset. 
%   Idx: Remaining indices.
%
% Revisions:
% 2020-Sep-10   function was created

%% Initialization
ErrorMsg= '';
Subsets = {};
Idx = (1:length(Labels));

%% Selection Mode
if nargin<4
    single_select = false;
end

if single_select
    SelectionMode = 'single';
else
    SelectionMode = 'multiple';
end

%% Select Subsets
while length(Subsets)<NumSubSets && ~isempty(Idx)
    
    if NumSubSets==1
        PromptString = prompt;
    else
        PromptString = sprintf('%s: %d from %d',prompt,length(Subsets)+1,min(NumSubSets,length(Subsets)+length(Idx)));
    end
    
    [subset,ok] = listdlg('Name','Selection Dialog','PromptString',PromptString,...
        'ListSize',[400 400],'SelectionMode',SelectionMode,'ListString',Labels(Idx));
    
    if ~ok 
        if isempty(Subsets)
            ErrorMsg = 'Process is aborted. No selection was made.';
            return;
        else
            return;
        end
    end
    
    subset = Idx(subset);
    Subsets{end+1} = subset;
    Idx = setdiff(Idx,subset);
    
end