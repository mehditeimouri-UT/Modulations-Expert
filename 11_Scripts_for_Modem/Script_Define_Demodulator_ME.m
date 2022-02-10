function ErrorMsg = Script_Define_Demodulator_ME

% This function gets the parameter of demodulation from user and defines demodulator.
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
% 2020-Sep-14   function was created

%% Initialization
global modulator_ME
global demodulator_ME
global message_ME
global View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME

%% Determine if Demodulator is same as Modulator
[ErrorMsg,Subsets,~] = Select_from_List_ME({'Same as Modulator','User Specific'},1,'Demodulator Definition Method',true);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Get Modulator Parameters and Define Modulation
switch Subsets{1}
    case 1
        
        demodulator_ME = modulator_ME;
                
    case 2
        
        [Mod,ErrorMsg] = Get_Modulation_Parameters_and_Define_Modulator_ME(message_ME.Type);
        if ~isempty(ErrorMsg)
            return;
        end
        
        demodulator_ME = Mod;        
end


%% Enable Next Box in Modem Block
View_Demodulator_PushButton_ME.Enable = 'on';
Apply_Demodulation_PushButton_ME.Enable = 'on';
Demodulated_Data_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.BackgroundColor = [1 1 1];