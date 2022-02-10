function ErrorMsg = Script_Define_Modulator_ME

% This function gets the parameter of modulation from user and defines modulator.
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
% 2020-Sep-13   function was created

%% Initialization
global message_ME
global modulator_ME
global View_Modulator_PushButton_ME Apply_Modulation_PushButton_ME Modulated_Data_PushButton_ME
global Define_Channel_PushButton_ME View_Channel_PushButton_ME Apply_Channel_PushButton_ME Channel_Output_PushButton_ME
global Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Get Modulator Parameters and Define Modulation
[Mod,ErrorMsg] = Get_Modulation_Parameters_and_Define_Modulator_ME(message_ME.Type);
if ~isempty(ErrorMsg)
    return;
end
modulator_ME = Mod;

%% Enable Next Box in Modem Block
View_Modulator_PushButton_ME.Enable = 'on';
Apply_Modulation_PushButton_ME.Enable = 'on';
Modulated_Data_PushButton_ME.Enable = 'off';
Modulated_Data_PushButton_ME.BackgroundColor = [1 1 1];

Define_Channel_PushButton_ME.Enable = 'off';
View_Channel_PushButton_ME.Enable = 'off';
Apply_Channel_PushButton_ME.Enable = 'off';
Channel_Output_PushButton_ME.Enable = 'off';
Channel_Output_PushButton_ME.BackgroundColor = [1 1 1];

Define_Demodulator_PushButton_ME.Enable = 'off';
View_Demodulator_PushButton_ME.Enable = 'off';
Apply_Demodulation_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.BackgroundColor = [1 1 1];