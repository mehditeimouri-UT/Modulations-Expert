function [Filename,Content,Fs,ErrorMsg] = Load_AudioFile_ME(dlg_title)

% This function gets an audio file file and reads some samples from this audio data.
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
% Input:
%   dlg_title: The title for load audio file dialog box
%       Note: If this input is not provided, the default title is used. 
%
% Outputs:
%   Filename: Audio file name.
%   Content: The samples read from audio file. 
%       Note: Content has at most MaxDataChannels_ME rows; Each row is a channel.
%   Fs: The sampling frequency of audio samples. 
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty. 
%
% Revisions:
% 2020-Sep-13   function was created

%% Initialization
global MaxDataChannels_ME MinInformationLength MaxInformationLength
Content = [];
Fs = [];
if nargin==0
    dlg_title = 'Load Audio File';
end

%% Get file from user
[Filename,path] = uigetfile({'*.wav;*.ogg;*.flac;*.au;*.aiff;*.aif;*.aifc;*.mp3;*.mp4' 'Audio Files'},dlg_title);
FullFileName = [path Filename];
if isequal(FullFileName,[0 0])
    Filename = [];
    ErrorMsg = 'No audio file is selected!';
    return;
end

%% Get File Info
try
    info = audioinfo(FullFileName);
catch
    ErrorMsg = 'The audio file type is not supported.';
    return;
end

if info.TotalSamples<MinInformationLength
    ErrorMsg = sprintf('The audio file length is less than %d samples.',MinInformationLength);
    return;
end

%% Get Parameters for Reading samples
[success,start,L] = PromptforParameters_ME({sprintf('Start sample (<=%d)',info.TotalSamples),sprintf('Length of Data (%d~%d)',MinInformationLength,min(info.TotalSamples,MaxInformationLength))},{'1',num2str(MinInformationLength)},...
    'Parameters for Parameters for Reading Audio File');
if ~success
    ErrorMsg = 'Parameters for Reading Audio File were not provided.';
    return;
end

% Check: start is positive integer scalar less than info.TotalSamples
ErrorMsg = Check_Variable_Value_ME(start,'Start sample','type','scalar','class','real',...
    'class','integer','min',1,'max',info.TotalSamples);
if ~isempty(ErrorMsg)
    return;
end

% Check: L is integer scalar and MinInformationLength<=L<=MaxInformationLength
ErrorMsg = Check_Variable_Value_ME(L,'Length of Data','type','scalar','class','real',...
    'class','integer','min',MinInformationLength,'max',MaxInformationLength);
if ~isempty(ErrorMsg)
    return;
end

% Check: final = start+L-1 is integer scalar and endpos<=info.TotalSamples
final = start+L-1;
ErrorMsg = Check_Variable_Value_ME(final,'Final sample','type','scalar','class','real',...
    'class','integer','max',info.TotalSamples);
if ~isempty(ErrorMsg)
    return;
end

%% Read file
[Content,Fs] = audioread(FullFileName,[start final]);
Content(:,MaxDataChannels_ME+1:end) = [];
Content = Content';