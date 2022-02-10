function [Filename,Content,ErrorMsg] = Load_MATFile_ME(dlg_title)

% This function gets a MAT file and returns one of its variables.
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
% Input:
%   dlg_title: The title for load file dialog box
%       Note: If this input is not provided, the default title is used. 
%
% Outputs:
%   Filename: MAT-file name corresponding to loaded variable.
%   Content: The loaded variable. 
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty. 
%
% Revisions:
% 2020-Sep-10   function was created

%% Initialization
Content = [];
if nargin==0
    dlg_title = 'Load MAT-File';
end

%% Get file from user
[Filename,path] = uigetfile('*.mat',dlg_title);
FullFileName = [path Filename];
if isequal(FullFileName,[0 0])
    Filename = [];
    ErrorMsg = 'No MAT-file is selected!';
    return;
end

%% Read file
matObj = matfile(FullFileName);
varlist = who(matObj);
[ErrorMsg,Subsets,~] = Select_from_List_ME(varlist',1,'Select Desired Variable',true);

if ~isempty(ErrorMsg)
    return;
end
Content = matObj.(varlist{Subsets{1}});