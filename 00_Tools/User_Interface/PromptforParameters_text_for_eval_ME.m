function str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title)

% This function in fact is equivalent to PromptforParameters_ME function.
% It is employed in situations that we are not certain about the number of
% output parameters.
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
%   Param_Names: 1xN cell of strings that determines the name of output
%       variables.
%   Param_Description: 1xN cell of strings that determines the description
%       of output variables.
%   Default_Value: 1xN cell of strings that determines the default values
%       of output variables.
%   dlg_title: Title for inputdlg
%
% Output:
%   str_cmd: A MATLAB command that can be run using eval function.
%
% Revisions:
% 2020-Sep-21   function was created

str_cmd = sprintf('[success');
for j=1:length(Param_Names)
    str_cmd = sprintf('%s,%s',str_cmd,Param_Names{j});
end
str_cmd = sprintf('%s] = PromptforParameters_ME({',str_cmd);

for j=1:length(Param_Description)
    str_cmd = sprintf('%s''%s'',',str_cmd,Param_Description{j});
end
str_cmd(end) = [];
str_cmd = sprintf('%s},{',str_cmd);

for j=1:length(Default_Value)
    str_cmd = sprintf('%s''%s'',',str_cmd,Default_Value{j});
end
str_cmd(end) = [];
str_cmd = sprintf('%s},''%s'');',str_cmd,dlg_title);