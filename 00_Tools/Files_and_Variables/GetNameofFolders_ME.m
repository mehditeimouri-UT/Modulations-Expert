function Foldernames = GetNameofFolders_ME(folder_name,varargin)

% This function returns name of all folders that contain at least one file
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
% Inputs
%   folder_name: Target folder
%
%   varargin{1}: 1xN cell that contains the name of all folders
%       When the number of inputs is equal to two
%
% Outputs
%   Foldernames: 1xN cell that contains the name of all folders
%
% Revisions:
% 2020-Sep-17   function was created

%% Parameters
Threshold = 1; % Minimum number of files in a folder

%% Check inputs and initialize output
if nargin==1
    Foldernames = cell(1,0);
else
    Foldernames = varargin{1};
end

%% List folder contents
listing = dir(folder_name);

%% Check the current folder
IsFile = ~arrayfun(@(x) x.isdir,listing);
if sum(IsFile)>=Threshold
    Foldernames{end+1} = folder_name;
end

%% Count files in the directories
idx = find(~IsFile);
for i=1:length(idx)
    j = idx(i);
    if listing(j).name(1)=='.'
        continue;
    end
    
    Foldernames = GetNameofFolders_ME([folder_name '\' listing(j).name],Foldernames);
end