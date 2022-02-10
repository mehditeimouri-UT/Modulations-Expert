function [Filenames,varargout] = GetNameofFiles_ME(includesubfolders,folder_name,filter_ext,varargin)

% This function returns name of files in a folder and (optionally) all its subfolders.
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
%   includesubfolders: If true, all subfolders are also included in the
%   search process. 
%   folder_name: Target folder
%   filter_ext: A 1xL cell, containing acceptable file extensions.
%       If filter_ext is empty, no filter is applied. 
%
%   varargin{1}: Number of files
%       When the number of inputs is equal to four
%
%   varargin{1}: 1xN cell that contains the name of all files
%   varargin{2}: counter for varargin{1}
%       When the number of inputs is equal to five
%
% Outputs
%   Filenames: 1xN cell that contains the name of all files
%   varargout{1}: counter for Filenames
%       When the number of outputs is equal to two
%
% Revisions:
% 2020-Sep-17   function was created

%% Check inputs and initialize output
if nargin==4
    N = varargin{1};
    Filenames = cell(1,N);
    cnt = 0;    
else
    Filenames = varargin{1};
    cnt = varargin{2};     
end

%% List folder contents
listing = dir(folder_name);

%% Get files in the current folder
IsFile = ~arrayfun(@(x) x.isdir,listing);
idx = find(IsFile);
for i=1:length(idx)
    
    j = idx(i);
    
    if ~isempty(filter_ext)
        [~,~,ext] = fileparts(listing(j).name);        
        if ~ismember(lower(ext),filter_ext)
            continue;
        end
    end
    
    cnt = cnt+1;
    Filenames{cnt} = [folder_name '\' listing(j).name];
    
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
    
    [Filenames,cnt] = GetNameofFiles_ME(includesubfolders,[folder_name '\' listing(j).name],filter_ext,Filenames,cnt);    
end

%% Varargout
varargout{1} = cnt;