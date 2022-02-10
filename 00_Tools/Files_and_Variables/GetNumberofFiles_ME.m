function N = GetNumberofFiles_ME(includesubfolders,folder_name,filter_ext)

% This function returns number of files in a main folder and (optionally) all its subfolders
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
%   includesubfolders: If true, all subfolders are also included.
%   folder_name: Target folder
%   filter_ext (Optional input): A 1xL cell, containing acceptable file extensions.
%       If filter_ext is empty, no filter is applied. 
%
% Outputs
%   N: Number of files
%
% Revisions:
% 2020-Sep-17   function was created

%% Initialzation
if nargin<3
    filter_ext = {};
end

%% List folder contents
listing = dir(folder_name);

%% Count files in the current folder
IsFile = ~arrayfun(@(x) x.isdir,listing);
if ~isempty(filter_ext)
    idx = find(IsFile);
    N = 0;
    for t=1:length(idx)
        [~,~,ext] = fileparts(listing(idx(t)).name);
        if ismember(lower(ext),filter_ext)
            N = N+1;
        end
    end
else
    N = sum(IsFile);
end

%% Return if subfolders are not included
if ~includesubfolders
    return;
end

%% Count files in the directories
idx = find(~IsFile);
for i=1:length(idx)
    j = idx(i);
    if listing(j).name(1)=='.'
        continue;
    end
    
    N = N+GetNumberofFiles_ME(includesubfolders,[folder_name '\' listing(j).name],filter_ext);
    
end