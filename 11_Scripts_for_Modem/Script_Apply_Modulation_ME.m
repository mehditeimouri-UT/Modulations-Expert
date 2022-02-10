function Script_Apply_Modulation_ME

% This function applies the defined modulator on unmodulated data. 
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
% Revisions:
% 2020-Sep-14   function was created

%% Initialization
global message_ME
global modulator_ME
global modulator_output_ME
global Modulated_Data_PushButton_ME
global Define_Channel_PushButton_ME View_Channel_PushButton_ME Apply_Channel_PushButton_ME Channel_Output_PushButton_ME
global Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Message Format
msg = message_ME.Content;
if isequal(modulator_ME.Type,'isb')
    if size(msg,1)==1
        msg = repmat(msg,2,1);
    end
    msg(3:end,[]) = [];
elseif size(msg,1)>1
    msg = mean(msg,1);
end

%% Apply Modulator
modulator_output_ME = [];
modulator_output_ME.Content = perform_modulation_ME(modulator_ME,msg);
if strcmpi(message_ME.Type,'Digital')
    modulator_output_ME.fs = message_ME.BitRate/log2(modulator_ME.M)*modulator_ME.sps;
else
    modulator_output_ME.fs = message_ME.Fs*modulator_ME.sps;
end

%% Enable Next Box in Modem Block
Modulated_Data_PushButton_ME.Enable = 'on';
Modulated_Data_PushButton_ME.BackgroundColor = [0 1 0];

Define_Channel_PushButton_ME.Enable = 'on';
View_Channel_PushButton_ME.Enable = 'off';
Apply_Channel_PushButton_ME.Enable = 'off';
Channel_Output_PushButton_ME.Enable = 'off';
Channel_Output_PushButton_ME.BackgroundColor = [1 1 1];

Define_Demodulator_PushButton_ME.Enable = 'off';
View_Demodulator_PushButton_ME.Enable = 'off';
Apply_Demodulation_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.BackgroundColor = [1 1 1];