function stopbar = progressbar_ME(varargin)

% This function employes progressbar function in order to easily handle nested
% progress bars.
%
% Note: This function assumes that the progress bar is initialized using
% progressbar function.
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
%   If varargin{i}; i<=3 are string values
%       progress bar is initiailized.
%   else
%       varargin{1} is prg_idx: Indication of using progressbar function
%           0: Means no progressbar is needed.
%           1: Means that the 1st progressbar should be used to indicate progress.
%           2: Means that the 2nd progressbar should be used to indicate progress.
%           3: Means that the 3rd progressbar should be used to indicate progress.
%       varargin{2} is prg: Progress value (0~1)
%
% Output:
%   stopbar: When detecting user termination, this output is true.
%
% Revisions:
% 2020-Aug-26   function was created
% 2020-Nov-12   Moving progressbar on top of all other figures (using command progressbar_ME()) was added.               

%% Moving progressbar on top of all other figures 
if nargin==0
    stopbar = progressbar(-1);
    return;
end

%% Initialize Progress Bars
if ischar(varargin{1})
    N = nargin;
    switch N
        case 1
            stopbar = progressbar(varargin{1});
        case 2
            stopbar = progressbar(varargin{1},varargin{2});
        case 3
            stopbar = progressbar(varargin{1},varargin{2},varargin{3});
    end
    return;
end

%% Indicating progress
prg_idx = varargin{1};
prg = varargin{2};
if prg_idx==0
    
    stopbar = false;
    return;

elseif prg_idx==1
    
    stopbar = progressbar(prg);
    return;
    
elseif prg_idx==2
    
    stopbar = progressbar([],prg);
    return;
    
elseif prg_idx==3
    
    stopbar = progressbar([],[],prg);
    return;
    
end