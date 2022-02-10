function [success,varargout] = PromptforParameters_ME(prompt,defaultanswerwer,dlg_title)

% This function gets analysis numerical/string parameters via a dialog box
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
%   prompt: A 1xN string cell, each element describes the related parameter
%   defaultanswerwer: A 1xN string cell, each element contains the default parameter
%   dlg_title: Title for inputdlg
%
% Output:
%   success: is true if parameters are obtained
%   varargout: variable number of outputs

% Revisions:
% 2020-Sep-10   function was created

%% Assign empty matrix to each output
success = false;
varargout = cell(1,length(prompt));

if nargout~=(length(prompt)+1)
    error('Unpredicted Error: Number of outputs do not match with prompt');
end

%% Get Parameters
num_lines = [1 100];
options.Resize='on';
options.WindowStyle='modal';
options.Interpreter='tex';

answer = inputdlg(prompt,dlg_title,num_lines,defaultanswerwer,options);
if (isempty(answer))
    return;
end

for i=1:length(prompt)
    
    if isequal(answer{i},'linear') || isequal(answer{i},'gray') % Special cases
        varargout{i} = answer{i};
        continue;
    end
    
    tmp = str2num(answer{i});
    if isempty(tmp)
        varargout{i} = answer{i};
    else
        varargout{i} = tmp;
    end
end
success = true;