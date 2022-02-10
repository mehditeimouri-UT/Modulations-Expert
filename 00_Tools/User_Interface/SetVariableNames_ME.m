function OutputLabels = SetVariableNames_ME(InputLabels,CheckVariable)

% This function takes an initial variable list of variable names. Then by
% prompting the user, takes valid names that can be used as variable names.
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
%   InputLabels: 1xN cell. Cell contents are strings denoting the initial
%       variable names.
%   CheckVariable (Optional): If false, the names are not checked for being
%       valid varibale. 
%
% Outputs:
%   OutputLabels: 1xN cell. Cell contents are strings denoting the selected
%   variable names.
%
% Revisions:
% 2020-Sep-21   function was created

%% Initialization
MultipleNameSelection = 10; % Determines the number of names that can be determined in one round of prompting
if nargin<2
    CheckVariable = true;
end

if CheckVariable
    dlg_title = 'Confirm Variable Names';
else
    dlg_title = 'Confirm Labels';
end

%% Check Input and Initialize Output
InputLabels = InputLabels(:)';
for i = 1:length(InputLabels)
    x = InputLabels{i};
    if iscell(x) % Multiple names are provided: Merging is needed
        y = '';
        for j=1:length(x)
            y = sprintf('%s-%s',y,x{j});
        end
        y(1) = [];
        InputLabels{i} = y;
    end
end

if CheckVariable
    OutputLabels = matlab.lang.makeValidName(InputLabels);
else
    OutputLabels = InputLabels;
end

%% Get New-Labels
for j=1:MultipleNameSelection:length(InputLabels)
    
    % Prepare prompt values
    if (j+MultipleNameSelection-1)<=length(InputLabels)
        idx = j:j+MultipleNameSelection-1;
    else
        idx = j:length(InputLabels);
    end
    x = InputLabels(idx);
    x = x(:)';
    y = OutputLabels(idx);
    y = y(:)';
    
    % Prepare prompt texts
    prompt = x;
    
    % Prompt user
    while true
        
        z = inputdlg(prompt,dlg_title,[1 50],y);
        if isempty(z)
            h = warndlg('Please confirm variable name(s)','Warning','modal');
            waitfor(h);
            continue;
        end
        y = z;
        
        success = true;
        if CheckVariable
            for i=1:length(idx)
                
                try
                    eval(sprintf('%s%d = 1;',y{i},randi([1 1e6],[1 1])));
                catch
                    h = warndlg(sprintf('Please enter a valid name for variable %d',i),'Invalid Name','modal');
                    waitfor(h);
                    success = false;
                    break;
                end
                
            end
        end
        
        if success
            
            OutputLabels(idx) = y;
            
            [UniqueOutputLabels,UniqueIdx] = unique(OutputLabels);
            if length(UniqueOutputLabels)~=length(OutputLabels)
                nonUniqueIdx = setdiff(1:length(OutputLabels),UniqueIdx);
                h = warndlg(sprintf('Duplicate name: %s',OutputLabels{nonUniqueIdx(1)}),'Invalid Name','modal');
                waitfor(h);
                continue;
            end
            
            break;
        end
        
    end
end