% This function displays information in a structure. 
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
%   S: A structure with arbitrary fields
%   dlg_title: Title for message box
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%
% Revisions:
% 2020-Sep-13   function was created

function Display_Sturcture_Info_ME(S,dlg_title)

%% Get Field Names
Names = fieldnames(S);

%% Concatenate Information
Msg = {};
for j=1:length(Names)
    
    tmp = S.(Names{j});    
    if isempty(tmp) || isstruct(tmp)
        continue;
    end
    
    if ischar(tmp)
        Msg{end+1} = sprintf('%s: %s',Names{j},tmp);
    elseif isscalar(tmp)
        Msg{end+1} = sprintf('%s: %g',Names{j},tmp);
    elseif ismatrix(tmp)
        Msg{end+1} = sprintf('%s: Data with size %dx%d',Names{j},size(tmp,1),size(tmp,2));
    end
        
end

%% Show Information
helpdlg(Msg,dlg_title);