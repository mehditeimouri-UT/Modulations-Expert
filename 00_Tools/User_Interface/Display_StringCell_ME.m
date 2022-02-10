function Display_StringCell_ME(cell_str,title)

% This function displays a cell of strings as a list box in modal style. 
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
%   cell_str: 1xN cell of strings
%   title: The string that should be displayed for the list
%
% Revisions:
% 2020-Sep-22   function was created

%% Display List Box
Listbox_ME_fig = figure;
set(Listbox_ME_fig,'Name',title,'NumberTitle','off','Toolbar','None','MenuBar','None','WindowStyle','modal');
uicontrol(Listbox_ME_fig,'style','listbox','String',cell_str,'Units','normalized','Position',[0 0.1 1 0.9]);

%% Define Close Button
uicontrol(Listbox_ME_fig,'Style', 'pushbutton', 'String', '<--- Go back',...
    'BackgroundColor',[0.3 0.7 0.5],'Units','normalized','Position', [0 0 1 0.1],...
    'Enable','on','Callback','closereq');