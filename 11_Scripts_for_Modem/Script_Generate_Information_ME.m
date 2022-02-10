function ErrorMsg = Script_Generate_Information_ME

% This function generates a random binary data stream.  
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
% 2020-Sep-10   function was created

%% Initialization
global message_ME
global Unmodulated_information_PushButton_ME
global Define_Modulator_PushButton_ME View_Modulator_PushButton_ME Apply_Modulation_PushButton_ME Modulated_Data_PushButton_ME
global Define_Channel_PushButton_ME View_Channel_PushButton_ME Apply_Channel_PushButton_ME Channel_Output_PushButton_ME
global Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME
global MinInformationLength MaxInformationLength TypicalInformationLength

%% Get Parameters for Data Generation
[success,L,p,BitRate] = PromptforParameters_ME({sprintf('Length of Data (between %d and %d)',MinInformationLength,MaxInformationLength),'Probability of one-bits','bit-rate in bits/sec'},{num2str(TypicalInformationLength),'0.5','1'},'Parameters for Generating Random Digital Data');
if ~success
    ErrorMsg = 'Parameters for Generating Random Digital Data were not provided.';
    return;
end

% Check: L is integer scalar and MinInformationLength<=L<=MaxInformationLength
ErrorMsg = Check_Variable_Value_ME(L,'Length of Data','type','scalar','class','real',...
    'class','integer','min',MinInformationLength,'max',MaxInformationLength);
if ~isempty(ErrorMsg)
    return;
end

% Check: p is real scalar and 0<=p<=1
ErrorMsg = Check_Variable_Value_ME(p,'Probability of one-bits','type','scalar',...
    'class','real','min',0,'max',1);
if ~isempty(ErrorMsg)
    return;
end

% Check: BitRate is real scalar BitRate>0
ErrorMsg = Check_Variable_Value_ME(BitRate,'Bit-rate','type','scalar','class','real',...
    'min',eps);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Generate Random Data
message_ME = [];
message_ME.Type = 'Digital';
message_ME.Content = randsrc(1,L,[0 1; 1-p p]);
message_ME.BitRate = BitRate;
message_ME.Filename = '';

%% Enable Next Box in Modem Block 
Unmodulated_information_PushButton_ME.Enable = 'on';
Unmodulated_information_PushButton_ME.BackgroundColor = [0 1 0];

Define_Modulator_PushButton_ME.Enable = 'on';
View_Modulator_PushButton_ME.Enable = 'off'; 
Apply_Modulation_PushButton_ME.Enable = 'off'; 
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