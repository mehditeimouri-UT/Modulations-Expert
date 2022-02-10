function ErrorMsg = Script_Load_IQ_Information_ME

% This function loads I/Q data into AMR block in one of the following ways:
%   1. It gets a binary *.dat file with 'FFFFFFF0' header and loads one of its bursts into AMR.
%       Note: For more information about the format of binary *.dat see Script_Generate_Dataset_of_Bursts_for_Digital_Modulations_ME.m.
%   2. It gets an stereo WAV file with I/Q sample and reads a portion of its samples.
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
global IQ_information_PushButton_ME
global Define_IQ_Demodulator_PushButton_ME View_IQ_Demodulator_PushButton_ME Apply_IQ_Demodulator_PushButton_ME Demodulated_IQ_PushButton_ME
global MinimumBurstLength
global IQ_Demodulator_Parameters_Estimation_PushButton_ME IQ_Blind_Demodulator_PushButton_ME
global IQ_EstimationResults_Text_ME

%% Determine Data Type
Menus = {'Load from binary DAT file of bursts','Load from stereo WAV file'};
[ErrorMsg,Subsets,~] = Select_from_List_ME(Menus,1,'Select Data to Load',true);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

switch Menus{Subsets{1}}
    
    case 'Load from binary DAT file of bursts'
        
        % Get Data File and Open The File
        [FileName,PathName] = uigetfile({'*.dat' , 'Data File'},'Load Dataset of Bursts');
        if isequal(FileName,0)
            ErrorMsg = 'Process is aborted. No file was selected by user.';
            return;
        end
        
        fileID = fopen([PathName FileName],'r');
        if isequal(fileID,-1)
            ErrorMsg = sprintf('Cannot open %s for reading.',FileName);
            return;
        end
        
        % Read File Information        
        % File Identifier; For digital Modulations it is always equal to 1
        header = fread(fileID,8,'char*1=>char',0,'b');
        header = header';
        if ~strcmp(header,'FFFFFFF0')
            ErrorMsg = sprintf('%s is not a valid data file.',FileName);
            fclose(fileID);
            return;
        end
        
        N = 0; % Number of Bursts
        while(true)
            
            fread(fileID,(1),'uint64=>double',0,'b'); % File Identifier
            if feof(fileID)
                break;
            end
            
            L = fread(fileID,(1),'uint64=>double',0,'b'); % Burst Length
            fseek(fileID,(2*L+1)*(8),'cof'); % Skip Burst
            N = N+1;
            
        end
        if N==0
            ErrorMsg = sprintf('%s does not contain any burst.',FileName);
            fclose(fileID);
            return;
        end
        
        % Get Target Burst Information
        [success,j] = PromptforParameters_ME(...
            {sprintf('Burst index to read (1~%d)',N)},...
            {'1'},...
            'Read Burst Parameters');
        if ~success
            ErrorMsg = 'Parameters for Read Burst were not provided.';
            fclose(fileID);
            return;
        end
        
        % Check: j is integer scalar and 1<=j<=N
        ErrorMsg = Check_Variable_Value_ME(j,'Burst index','type','scalar',...
            'class','real','class','integer','min',1,'max',N);
        if ~isempty(ErrorMsg)
            fclose(fileID);
            return;
        end
        
        % Read Target Burst
        % File Header
        fseek(fileID,(8)*(1),'bof'); % Skip Header
        
        N = 0; % Number of Bursts
        while(true)
            
            fseek(fileID,(1)*(8),'cof'); % Skip File Identifier
            L = fread(fileID,(1),'uint64=>double',0,'b'); % Burst Length
            N = N+1;
            
            if N==j
                
                fs = fread(fileID,(1),'double',0,'b'); % Sampling Frequency
                xr = fread(fileID,(L),'double',0,'b'); % Real Part
                xi = fread(fileID,(L),'double',0,'b'); % Imaginary Part
                x = complex(xr',xi');
                
                % Write Signal
                iq_information_ME = [];
                iq_information_ME.Content = x;
                iq_information_ME.fs = fs;
                
                fclose(fileID);
                break;
                
            else
                
                fseek(fileID,(2*L+1)*(8),'cof'); % Skip Burst
                
            end
            
        end
        
        
    case 'Load from stereo WAV file'
        
        % Get WAV File
        [FileName,PathName] = uigetfile({'*.wav' , 'WAV File'},'Load WAV File Containing I/Q Data');
        if isequal(FileName,0)
            ErrorMsg = 'Process is aborted. No file was selected by user.';
            return;
        end
        
        % Get audio info; Continue if file is invalid or too short
        audiofilename = [PathName FileName];
        try
            info = audioinfo(audiofilename);
            if info.TotalSamples<MinimumBurstLength || info.NumChannels~=2
                ErrorMsg = 'The Audio file is too short or it does not have two channels.';
                return;
            end
        catch
            ErrorMsg = 'The selected file is not a valid audio file.';
            return;
        end
        
        % Get Target Portion of Data
        [success,j,L] = PromptforParameters_ME(...
            {sprintf('Start Index (1~%d)',info.TotalSamples-MinimumBurstLength+1),sprintf('Length of Data (%d~%d)',MinimumBurstLength,info.TotalSamples)},...
            {'1',num2str(min(4096,info.TotalSamples))},...
            'Parameters for reading data portion');
        if ~success
            ErrorMsg = 'Parameters for reading data portion.';
            return;
        end
        
        % Check: j is integer scalar and 1<=j<=info.TotalSamples-MinimumBurstLength+1
        ErrorMsg = Check_Variable_Value_ME(j,'Start of Data Portion','type','scalar',...
            'class','real','class','integer','min',1,'max',info.TotalSamples-MinimumBurstLength+1);
        if ~isempty(ErrorMsg)
            return;
        end
        
        % Check: L is integer scalar and MinimumBurstLength<=L<=info.TotalSamples-j+1
        ErrorMsg = Check_Variable_Value_ME(L,'Length of Data Portion','type','scalar',...
            'class','real','class','integer','min',MinimumBurstLength,'max',info.TotalSamples-j+1);
        if ~isempty(ErrorMsg)
            return;
        end
        
        % Read Data Portion
        [x,Fs] = audioread(audiofilename,[j j+L-1]);
        
        % Form I/Q
        y = complex(x(:,1)',x(:,2)');
        
        % Write Signal
        iq_information_ME = [];
        iq_information_ME.Content = y;
        iq_information_ME.fs = Fs;
        
end

%% Update GUI

% Message to User
GUI_MainEditBox_Update_ME(false,'I/Q Data is loaded successfully.');

% Enable Next Box in AMR Block
IQ_information_PushButton_ME.Enable = 'on';
IQ_information_PushButton_ME.BackgroundColor = [0 1 0];

Define_IQ_Demodulator_PushButton_ME.Enable = 'on';
View_IQ_Demodulator_PushButton_ME.Enable = 'off';
Apply_IQ_Demodulator_PushButton_ME.Enable = 'off';

IQ_Demodulator_Parameters_Estimation_PushButton_ME.Enable = 'on';
IQ_Blind_Demodulator_PushButton_ME.Enable = 'off';

Demodulated_IQ_PushButton_ME.BackgroundColor = [1 1 1];
Demodulated_IQ_PushButton_ME.Enable = 'off';

IQ_EstimationResults_Text_ME.String = '';