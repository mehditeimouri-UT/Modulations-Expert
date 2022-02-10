function Script_Apply_Channel_ME

% This function passes modulated data from AWGN channel.
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
global channel_ME
global modulator_output_ME
global channel_output_ME
global Channel_Output_PushButton_ME
global Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Apply AWGN
channel_output_ME = modulator_output_ME;
channel_output_ME.Content = AWGN_ME(modulator_output_ME.Content,channel_ME.SNR,false,false);
channel_output_ME.Content = channel_output_ME.Content(1+channel_ME.dt:end);

%% Enable Next Box in Modem Block
Channel_Output_PushButton_ME.Enable = 'on';
Channel_Output_PushButton_ME.BackgroundColor = [0 1 0];

Define_Demodulator_PushButton_ME.Enable = 'on';
View_Demodulator_PushButton_ME.Enable = 'off';
Apply_Demodulation_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.BackgroundColor = [1 1 1];