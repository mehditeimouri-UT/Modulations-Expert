function ErrorMsg = Script_Define_Channel_ME

% This function gets the parameter of AWGN channel from user and defines channel.
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
global channel_ME
global modulator_ME
global View_Channel_PushButton_ME Apply_Channel_PushButton_ME Channel_Output_PushButton_ME
global Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME

%% Get AWGN Channel Parameters
[success,SNR,dt] = PromptforParameters_ME(...
    {'SNR (dB)',sprintf('Time Delay (0~%d)',round(modulator_ME.sps)-1)},...
    {'10','0'},...
    'AWGN Channel Parameters');
if ~success
    ErrorMsg = 'Parameters for AWGN Channel were not provided.';
    return;
end

% Check: SNR is real scalar
ErrorMsg = Check_Variable_Value_ME(SNR,'SNR (dB) for AWGN channel','type','scalar',...
    'class','real');
if ~isempty(ErrorMsg)
    return;
end

% Check: dt is integer scalar and 0<=dt<sps
ErrorMsg = Check_Variable_Value_ME(dt,'Time delay in AWGN channel','type','scalar','class','real',...
    'class','integer','min',0,'max',modulator_ME.sps-1);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Define AWGN Channel
channel_ME = [];
channel_ME.SNR = SNR;
channel_ME.dt = dt;

%% Enable Next Box in Modem Block
View_Channel_PushButton_ME.Enable = 'on';
Apply_Channel_PushButton_ME.Enable = 'on';
Channel_Output_PushButton_ME.Enable = 'off';
Channel_Output_PushButton_ME.BackgroundColor = [1 1 1];

Define_Demodulator_PushButton_ME.Enable = 'off';
View_Demodulator_PushButton_ME.Enable = 'off';
Apply_Demodulation_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.Enable = 'off';
Demodulated_Data_PushButton_ME.BackgroundColor = [1 1 1];