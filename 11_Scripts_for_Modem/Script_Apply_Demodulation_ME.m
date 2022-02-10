function ErrorMsg = Script_Apply_Demodulation_ME

% This function applies the defined demodulator on channel output. 
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
global channel_output_ME demodulator_ME demodulated_message_ME
global Demodulated_Data_PushButton_ME
global AnalogModTypes DigitalModTypes LinearDigitalModTypes
ErrorMsg = '';

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Apply Demodulator
demodulated_message_ME = [];
switch demodulator_ME.Type
    case DigitalModTypes
        demodulated_message_ME.Type = 'Digital';
    case AnalogModTypes
        demodulated_message_ME.Type = 'Analog';
end

switch demodulator_ME.Type
    case LinearDigitalModTypes
        
        [demodulated_message_ME.Content,demodulated_message_ME.Constellation] = perform_demodulation_ME(demodulator_ME,channel_output_ME.Content);
        
    otherwise
        
        demodulated_message_ME.Content = perform_demodulation_ME(demodulator_ME,channel_output_ME.Content);
end

if isempty(demodulated_message_ME.Content)
    ErrorMsg = 'Process was aborted by user.';
    return;
end

if strcmpi(demodulated_message_ME.Type,'Digital')
    demodulated_message_ME.BitRate = (channel_output_ME.fs/demodulator_ME.sps)*log2(demodulator_ME.M);
else
    demodulated_message_ME.Fs = channel_output_ME.fs/demodulator_ME.sps;
end

%% Update GUI
GUI_MainEditBox_Update_ME(false,'Demodulation is completed.');

%% Enable Next Box in Modem Block
Demodulated_Data_PushButton_ME.Enable = 'on';
Demodulated_Data_PushButton_ME.BackgroundColor = [0 1 0];