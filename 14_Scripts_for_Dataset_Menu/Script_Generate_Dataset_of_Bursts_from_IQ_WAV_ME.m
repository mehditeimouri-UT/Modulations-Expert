function ErrorMsg = Script_Generate_Dataset_of_Bursts_from_IQ_WAV_ME

% This function gets a folder, in which there are some stereo wav files, and extracts some burst from them.
% The bursts are written into a binary *.dat file with 'FFFFFFF0' header
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
% 2020-Sep-27   function was created

%% Initialization
global MaximumBursts_per_AudioFile MinimumBurstLength MaximumBurstLength

%% Get Bursts Parameters
[success,N,Ls,independent_fid] = PromptforParameters_ME(...
    {sprintf('Maximum Number of Bursts per Audio File (1~%d)',MaximumBursts_per_AudioFile),sprintf('Bursts Possible Lengths (in samples, %d~%d)',MinimumBurstLength,MaximumBurstLength),'Assign Different File Identifiers for Bursts in the Same WAV File'},...
    {num2str(MaximumBursts_per_AudioFile),'4096','true'},...
    'Burst Parameters');
if ~success
    ErrorMsg = 'Parameters for Burst Generation were not provided.';
    return;
end

% Check: N is a scalar with integer value and MaximumBursts_per_AudioFile>=N>=1
ErrorMsg = Check_Variable_Value_ME(N,'Total Number of Bursts','type','scalar',...
    'class','real','class','integer','min',1,'max',MaximumBursts_per_AudioFile);
if ~isempty(ErrorMsg)
    return;
end

% Check: Ls is a real vector with integers values MinimumBurstLength~MaximumBurstLength
ErrorMsg = Check_Variable_Value_ME(Ls,'Bursts Possible Lengths','type','vector',...
    'class','real','class','integer','min',MinimumBurstLength,'max',MaximumBurstLength);
if ~isempty(ErrorMsg)
    return;
end

%% Get input folder address
mainfoldername = uigetdir(pwd,'Select the main folder that contains the I/Q WAV files');
if isequal(mainfoldername,0)
    ErrorMsg = 'Process is aborted. No folder is selected.';
    return;
end

%% Get the names of all audio files
filter_ext = {'.wav'};
Nfiles = GetNumberofFiles_ME(true,mainfoldername,filter_ext);
if Nfiles==0
    ErrorMsg = 'The selected folder does not contain any audio wav file.';
    return;
end
AllFiles = GetNameofFiles_ME(true,mainfoldername,filter_ext,Nfiles);

%% Get Destination File
default_filename = mainfoldername; 
idx = find(default_filename=='\',1,'last');
if ~isempty(idx)
    default_filename(1:idx) = [];
end
[FileName,PathName] = uiputfile({'*.dat' , 'Data File'},'Save Dataset of Bursts as',[default_filename '.dat']);
if isequal(FileName,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Open Destination File
fileID = fopen([PathName FileName],'w');
if isequal(fileID,-1)
    ErrorMsg = sprintf('Cannot open %s for saving dataset.',FileName);
    return;
end

% File Header
fwrite(fileID,'FFFFFFF0','char*1',0,'b');

%% Generate Bursts
MaxAudioSamples = max(Ls);
progressbar_ME('Audio File Processing ...','Bursts Generation ...');
TotalFiles = 0;
TotalBursts = 0;
stopbar = false;
for i=1:Nfiles
    
    % Audio file name
    audiofilename = AllFiles{i};
    TotalFiles = TotalFiles+1;
    
    % Get audio info; Continue if file is invalid or too short
    try
        info = audioinfo(audiofilename);
        if info.TotalSamples<MaxAudioSamples || info.NumChannels~=2
            continue;
        end
    catch
        continue;
    end
    
    % Get audio fragments
    [Starts,Ends] = TakeRandomAudioFragments_ME(info.TotalSamples,Ls,0,0,N);
    
    % Generate Burst for each Audio File
    for j=1:length(Starts)
        
        % Read Burst
        [x,Fs] = audioread(audiofilename,[Starts(j) Ends(j)]);
        
        % Form I/Q
        y = complex(x(:,1)',x(:,2)');
        
        % Write Data
        TotalBursts = TotalBursts+1;
        if independent_fid
            fwrite(fileID,TotalBursts,'uint64',0,'b'); % File Identifier
        else
            fwrite(fileID,i,'uint64',0,'b'); % File Identifier
        end
        fwrite(fileID,length(y),'uint64',0,'b'); % Burst Length
        fwrite(fileID,Fs,'double',0,'b'); % Burst Sampling Rate
        fwrite(fileID,real(y),'double',0,'b'); % Burst Real Content
        fwrite(fileID,imag(y),'double',0,'b'); % Burst Real Content
        
        
        % Progress
        stopbar = progressbar_ME(2,j/length(Starts));
        if stopbar
            break;
        end
        
    end
    
    % Progress
    if stopbar
        break;
    end
    stopbar = progressbar_ME(1,i/Nfiles);
    if i<Nfiles && ~stopbar
        stopbar = progressbar_ME(2,0);
    end
    if stopbar
        break;
    end

    
end
progressbar_ME(1,1);
fclose(fileID);

%% Update GUI
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
if j<N
    GUI_MainEditBox_Update_ME(false,sprintf('The process of Burst Generation was aborted by user; Total Files: %d, Total Bursts: %d',TotalFiles,TotalBursts));
else
    GUI_MainEditBox_Update_ME(false,sprintf('The process of Analog Burst Generation is completed successfully; Total Files: %d, Total Bursts: %d',TotalFiles,TotalBursts));
end
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');