function ErrorMsg = Script_Present_IQ_Information_ME

% This function presents I/Q information in ones of the
% following ways:
%   (I) Power Spectral Density
%   (II) Signal Information
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
% Output:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%
% Revisions:
% 2020-Sep-16   function was created

%% Initialization
global iq_information_ME
global DecisionMachine_ME DecisionMachine_CL_ME
%% Determine Presentation Type
Menus = {'Power Spectral Density','Signal Information'};
if ~(isempty(DecisionMachine_ME) && isempty(DecisionMachine_CL_ME))
    Menus{end+1} = 'Modulation Recognition Using Decision Machine';
end
[ErrorMsg,Subsets,~] = Select_from_List_ME(Menus,1,'Select Presentation/Processing Type for I/Q Information',true);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Perform Operation
switch Menus{Subsets{1}}
    
    case 'Power Spectral Density'
        
        ErrorMsg = Plot_PSD_ME(iq_information_ME.Content,iq_information_ME.fs);
        if ~isempty(ErrorMsg)
            return;
        end
        
    case 'Signal Information'
        
        Display_Sturcture_Info_ME(iq_information_ME,'I/Q Information');
        
    case 'Modulation Recognition Using Decision Machine'
        
        ErrorMsg = Script_AMR_ME;        
        if ~isempty(ErrorMsg)
            return;
        end        
end
