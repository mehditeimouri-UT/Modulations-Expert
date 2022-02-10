function ErrorMsg = Script_Generate_Dataset_of_Bursts_for_Digital_Modulations_ME

% This function gets the parameters for a digital modulator and generates
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
% 2020-Dec-22   The functionality of getting multiple modulators of the same kind with
%               different parameters is now possible.

%% Initialization
global MinimumBursts_per_Modulation MaximumBursts_per_Modulation MinimumBurstLength MaximumBurstLength

%% Get Modulation Parameters and Define Modulator
[Mods,ErrorMsg] = Get_Modulation_Parameters_and_Define_Modulator_ME('Digital',true);
if ~isempty(ErrorMsg)
    return;
end

%% Get Bursts Parameters
[success,N,Ls,SNRs,dts,RndPhase,BitRate] = PromptforParameters_ME(...
    {sprintf('Total Number of Bursts (%d~%d)',MinimumBursts_per_Modulation,MaximumBursts_per_Modulation),sprintf('Bursts Possible Lengths (in samples, %d~%d)',MinimumBurstLength,MaximumBurstLength),'SNR Possible Values (in dB)','Possible Timing Offsets in Receieved Samples','Random Carrier initial phase of Modulator (true|false)','Bit Rate (bits/sec)'},...
    {'3000','4096','(15:20)',sprintf('(0:%d)',ceil(max(arrayfun(@(x) x.sps,Mods)))-1),'true','100'},...
    'Burst Parameters');
if ~success
    ErrorMsg = 'Parameters for Burst Generation were not provided.';
    return;
end

% Check: N is a scalar with integer value and MaximumBurstLength>=N>=MinimumBursts_per_Modulation
ErrorMsg = Check_Variable_Value_ME(N,'Total Number of Bursts','type','scalar',...
    'class','real','class','integer','min',MinimumBursts_per_Modulation,'max',MaximumBursts_per_Modulation);
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

% Check: BitRate is a positive scalar
ErrorMsg = Check_Variable_Value_ME(BitRate,'BitRate','type','scalar',...
    'class','real','min',eps);
if ~isempty(ErrorMsg)
    return;
end

%% Prompt User for
choice = questdlg(sprintf('On average, %g bursts will be generated for each modulator instance.\n\nMoreover, on average, %g bursts will be generated for each modulator instance at each SNR value.\n\nDo you want to continue?'...
    ,N/length(Mods),N/(length(SNRs)*length(Mods))),'Precaution','Yes','No','Yes');
if ~isequal(choice,'Yes')
    ErrorMsg = 'Process aborted by user.';
    return;
end

%% Calculate Sampling Delay in Each Burst and Determine Default Filename for Writing the Output
if strcmpi(Mods(1).Type,'oqpsk')
    
    delay = ceil(max(arrayfun(@(x) x.sps,Mods))/2);
    default_filename = sprintf('%s.dat',Mods(1).Type);
    
elseif strcmpi(Mods(1).Type,'msk') 
    
    delay = max(arrayfun(@(x) x.sps,Mods));
    default_filename = sprintf('%s.dat',Mods(1).Type);
    
elseif strcmpi(Mods(1).Type,'gmsk')
    
    delay = max(arrayfun(@(x) x.L,Mods))/2*max(arrayfun(@(x) x.sps,Mods));    
    default_filename = sprintf('%s.dat',Mods(1).Type);
    
else

    delay = 0;
    str_tmp = sprintf('%d-',unique(arrayfun(@(x) x.M,Mods)));
    default_filename = sprintf('%s-M-%s.dat',Mods(1).Type,str_tmp(1:end-1));    
    
end

%% Get Destination File
[FileName,PathName] = uiputfile({'*.dat' , 'Data File'},'Save Dataset of Bursts for Digital Modulation as',default_filename);
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
progressbar_ME('Generating Bursts ...');
for j=1:N
    
    % Index Random Modulator
    idx = randi([1 length(Mods)],[1 1]);
    
    % Random Phase
    if RndPhase 
        Mods(idx).ini_phase = 2*pi*rand(1,1);
    end
    
    % Randomly Select Burst Prameters
    L = Ls(randi([1 length(Ls)],[1 1]));
    SNR = SNRs(randi([1 length(SNRs)],[1 1]));
    dt = dts(randi([1 length(dts)],[1 1]));
    
    % Number of Symbols
    Nsyms = ceil((delay+L+dt+1)/Mods(idx).sps);
    
    % Generate Random Burst of Information
    data = randi([0 1],[1 Nsyms*log2(Mods(idx).M)]);
    
    % Modulate Data
    x = perform_modulation_ME(Mods(idx),data);
    
    % channel
    y = AWGN_ME(x,SNR,false,false);
    
    % Get Burst
    y = y(delay+dt+(1:L));
    
    % Write Data
    fwrite(fileID,j,'uint64',0,'b'); % File Identifier; For digital Modulations is sequentially increased.
    fwrite(fileID,length(y),'uint64',0,'b'); % Burst Length
    fwrite(fileID,BitRate/log2(Mods(idx).M)*Mods(idx).sps,'double',0,'b'); % Burst Sampling Rate
    fwrite(fileID,real(y),'double',0,'b'); % Burst Real Content
    fwrite(fileID,imag(y),'double',0,'b'); % Burst Real Content
    
    % Progress
    stopbar = progressbar_ME(1,j/N);
    if stopbar
        break;
    end
    
end
progressbar_ME(1,1);
fclose(fileID);

%% Update GUI
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
if j<N
    GUI_MainEditBox_Update_ME(false,sprintf('The process of Digital Burst Generation was aborted by user; Dataset file contains %d bursts',j));
else
    GUI_MainEditBox_Update_ME(false,'The process of Digital Burst Generation is completed successfully.');
end
GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');