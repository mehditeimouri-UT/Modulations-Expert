function ErrorMsg = Script_Load_Information_ME

% This function loads a sampled analog or a binary (0 and 1) data vector.
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
global MaxDataChannels_ME MinInformationLength MaxInformationLength

%% Determine Data Type
[ErrorMsg,Subsets,~] = Select_from_List_ME({'MAT File: Digital','MAT File: Analog','Audio File: Analog'},1,'Select Data Type',true);

if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Load Information
switch Subsets{1}
    
    case 1
        
        [Filename,Content,ErrorMsg] = Load_MATFile_ME('Load MAT-File containing digital data');
        if ~isempty(ErrorMsg)
            return;
        end
        
        % Check: Content is binary vector with 100<=Length<=1e7
        ErrorMsg = Check_Variable_Value_ME(Content,'Loaded vector','type','vector',...
            'class','real','unique-values',{[0 1],'are not binary'},'numel-min-max',[MinInformationLength MaxInformationLength]);
        if ~isempty(ErrorMsg)
            return;
        end
        
        % Get bit-rate
        [success,BitRate] = PromptforParameters_ME({'Enter bit-rate in bits/sec'},{'1'},'Bit-Rate');
        if ~success
            ErrorMsg = 'Bit-rate was not provided.';
            return;
        end
        
        % Check: BitRate is real scalar BitRate>0
        ErrorMsg = Check_Variable_Value_ME(BitRate,'Bit-rate','type','scalar','class','real',...
            'min',eps);
        if ~isempty(ErrorMsg)
            return;
        end
        
        message_ME = [];
        message_ME.Type = 'Digital';
        message_ME.Content = Content(:)';
        message_ME.BitRate = BitRate;
        message_ME.Filename = Filename;        
        
    case 2
        
        [Filename,Content,ErrorMsg] = Load_MATFile_ME('Load MAT-File containing analog data');
        if ~isempty(ErrorMsg)
            return;
        end
        
        % Check: Content is a real matrix with at most two channel and
        % 100<=L<=1e7 samples in each channel
        ErrorMsg = Check_Variable_Value_ME(Content,'Loaded vector','type','matrix',...
            'class','real','matrix-min-max-channels',[1 MaxDataChannels_ME],'matrix-channel-samples-min-max',[MinInformationLength MaxInformationLength]);
        if ~isempty(ErrorMsg)
            return;
        end
        
        if size(Content,1)>size(Content,2)
            Content = Content';
        end
        
        % Get sampling frequency
        [success,Fs] = PromptforParameters_ME({'Enter sampling frequency in Hz'},{'1'},'Sampling Frequency');
        if ~success
            ErrorMsg = 'Sampling frequency was not provided.';
            return;
        end
        
        % Check: Fs is real scalar Fs>0
        ErrorMsg = Check_Variable_Value_ME(Fs,'Sampling frequency','type','scalar','class','real',...
            'min',eps);
        if ~isempty(ErrorMsg)
            return;
        end
        
        message_ME = [];
        message_ME.Type = 'Analog';
        message_ME.Content = Content;
        message_ME.Fs = Fs;
        message_ME.Filename = Filename;
        
    case 3
        
        [Filename,Content,Fs,ErrorMsg] = Load_AudioFile_ME('Load Audio-File containing analog data');
        if ~isempty(ErrorMsg)
            return;
        end
        message_ME = [];
        message_ME.Type = 'Analog';
        message_ME.Content = Content;
        message_ME.Fs = Fs;
        message_ME.Filename = Filename;
        
end

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