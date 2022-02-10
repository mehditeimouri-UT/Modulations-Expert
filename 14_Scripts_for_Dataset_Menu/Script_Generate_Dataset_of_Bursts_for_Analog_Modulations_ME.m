function ErrorMsg = Script_Generate_Dataset_of_Bursts_for_Analog_Modulations_ME

% This function gets the parameters for an analog modulator and generates
% bursts modulated using this modulation type. The AWGN channel is assumed.
% The bursts are written in a binary *.dat file with 'FFFFFFF0' header
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
% 2020-Sep-15   function was created
% 2020-Dec-26   The functionality of getting multiple modulators of the same kind with
%               different parameters is now possible.

%% Initialization
global MaximumFragments_per_AudioFile MinimumBurstLength MaximumBurstLength

%% Get Modulation Parameters and Define Modulator
[Mods,ErrorMsg] = Get_Modulation_Parameters_and_Define_Modulator_ME('Analog',true);
if ~isempty(ErrorMsg)
    return;
end

%% Get Bursts Parameters
[success,N,Ls,SNRs,dts,RndPhase] = PromptforParameters_ME(...
    {sprintf('Maximum Number of Bursts per Audio File (1~%d)',MaximumFragments_per_AudioFile),sprintf('Bursts Possible Lengths (in samples, %d~%d)',MinimumBurstLength,MaximumBurstLength),'SNR Possible Values (in dB)','Possible Timing Offsets in Receieved Samples','Random Carrier initial phase of Modulator (true|false)'},...
    {'1','4096','[15 20]',sprintf('(0:%d)',ceil(max(arrayfun(@(x) x.sps,Mods)))-1),'true'},...
    'Burst Parameters');
if ~success
    ErrorMsg = 'Parameters for Burst Generation were not provided.';
    return;
end

% Check: N is a scalar with integer value and MaximumFragments_per_AudioFile>=N>=1
ErrorMsg = Check_Variable_Value_ME(N,'Maximum Number of Bursts per Audio File','type','scalar',...
    'class','real','class','integer','min',1,'max',MaximumFragments_per_AudioFile);
if ~isempty(ErrorMsg)
    return;
end

% Check: Ls is a real vector with integers values MinimumBurstLength~MaximumBurstLength
ErrorMsg = Check_Variable_Value_ME(Ls,'Bursts Possible Lengths','type','vector',...
    'class','real','class','integer','min',MinimumBurstLength,'max',MaximumBurstLength);
if ~isempty(ErrorMsg)
    return;
end

% Check: SNRs is a real vector
ErrorMsg = Check_Variable_Value_ME(SNRs,'SNR Possible Values','type','vector',...
    'class','real');
if ~isempty(ErrorMsg)
    return;
end

% Check: dts is a real vector with positive integers values
ErrorMsg = Check_Variable_Value_ME(dts,'Timing Offsets in Receieved Samples','type','vector',...
    'class','real','class','integer','min',0);
if ~isempty(ErrorMsg)
    return;
end

% Check: RndPhase is a real scalar with logical value
ErrorMsg = Check_Variable_Value_ME(RndPhase,'Random Carrier initial phase of Modulator','type','scalar',...
    'possiblevalues',{true,false});
if ~isempty(ErrorMsg)
    return;
end

%% Get input folder address
mainfoldername = uigetdir(pwd,'Select the main folder that contains the audio files');
if isequal(mainfoldername,0)
    ErrorMsg = 'Process is aborted. No folder is selected.';
    return;
end

%% Get the names of all audio files
filter_ext = {'.wav','.ogg','.flac','.au','.aiff','.aif','.aifc','.mp3','.mp4'};
Nfiles = GetNumberofFiles_ME(true,mainfoldername,filter_ext);
if Nfiles==0
    ErrorMsg = 'The selected folder does not contain any audio file.';
    return;
end
AllFiles = GetNameofFiles_ME(true,mainfoldername,filter_ext,Nfiles);

%% Prompt User for
choice = questdlg(sprintf('At most, on average, %g bursts will be generated for each modulator instance.\n\nMoreover, at most, on average, %g bursts will be generated for each modulator instance at each SNR value.\n\nDo you want to continue?'...
    ,(N*Nfiles)/length(Mods),(N*Nfiles)/(length(SNRs)*length(Mods))),'Precaution','Yes','No','Yes');
if ~isequal(choice,'Yes')
    ErrorMsg = 'Process aborted by user.';
    return;
end

%% Determine Default Filename for Writing the Output
default_filename = sprintf('%s.dat',Mods(1).Type);

%% Get Destination File
[FileName,PathName] = uiputfile({'*.dat' , 'Data File'},'Save Dataset of Bursts for Analog Modulation as',default_filename);
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
MaxAudioSamples = ceil((max(Ls)+max(dts)+1)/min(arrayfun(@(x) x.sps,Mods)));
progressbar_ME('Audio File Processing ...','Bursts Generation ...');
TotalFiles = 0;
TotalBursts = 0;
stopbar = false;
for i=1:Nfiles
    
    % Audio file name
    audiofilename = AllFiles{i};
    TotalFiles = TotalFiles+1;
    
    % Get audio info; Continue if file is invalid or is too short
    try
        info = audioinfo(audiofilename);
        if info.TotalSamples<MaxAudioSamples
            continue;
        end
    catch
        continue;
    end
    
    % Get audio fragments
    La = ceil(max(arrayfun(@(x) x.sps,Mods)))+ceil((Ls+max(dts))/min(arrayfun(@(x) x.sps,Mods)));
    [Starts,Ends] = TakeRandomAudioFragments_ME(info.TotalSamples,La,0,0,N);
    
    % Generate Burst for each Audio File
    for j=1:length(Starts)
        
        % Index Random Modulator
        idx = randi([1 length(Mods)],[1 1]);
        
        % Random Phase
        if RndPhase
            Mods(idx).ini_phase = 2*pi*rand(1,1);
        end
        
        % Randomly Select Burst Prameters
        SNR = SNRs(randi([1 length(SNRs)],[1 1]));
        dt = dts(randi([1 length(dts)],[1 1]));

        % format Message
        [msg,Fs] = audioread(audiofilename,[Starts(j) Ends(j)]);
        msg = msg';
        if isequal(Mods(idx).Type,'isb')
            if size(msg,1)==1
                msg = repmat(msg,2,1);
            end
            msg(3:end,[]) = [];
        elseif size(msg,1)>1
            msg = mean(msg,1);
        end        
        
        % Modulate Data
        x = perform_modulation_ME(Mods(idx),msg);
        
        % channel
        y = AWGN_ME(x,SNR,false,false);
        
        % Get Burst
        y = y(1+dt:end);
        y = y(1:Ls(La==(Ends(j)-Starts(j)+1)));        

        % Write Data
        fwrite(fileID,i,'uint64',0,'b'); % File Identifier
        fwrite(fileID,length(y),'uint64',0,'b'); % Burst Length
        fwrite(fileID,Fs*Mods(idx).sps,'double',0,'b'); % Burst Sampling Rate
        fwrite(fileID,real(y),'double',0,'b'); % Burst Real Content
        fwrite(fileID,imag(y),'double',0,'b'); % Burst Real Content
        TotalBursts = TotalBursts+1;
        
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
    GUI_MainEditBox_Update_ME(false,sprintf('The process of Analog Burst Generation was aborted by user; Total Files: %d, Total Bursts: %d',TotalFiles,TotalBursts));
else
    GUI_MainEditBox_Update_ME(false,sprintf('The process of Analog Burst Generation is completed successfully; Total Files: %d, Total Bursts: %d',TotalFiles,TotalBursts));
end
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');