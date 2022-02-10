function [Starts,Ends] = TakeRandomAudioFragments_ME(FileLength,PossiblePacketSizes,DisregardBOF,DisregardEOF,MaxFragment)

% This function takes some random fragments from an audio file. 
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
% Inputs
%   FileLength: Length of audio file in samples
%   PossiblePacketSizes: 1xn vector that contains the possible values for  packet size
%   DisregardBOF: A number in interval (0,1) that specifies the percent of fragments from begining of file which should be discarded
%   DisregardEOF: A number in interval (0,1) that specifies the percent of fragments from end of file which should be discarded
%   MaxFragment: Maximum number of fragments taken from a file
%
% Outputs
%   Starts: 1xMaxFragment (or less) start positions for fragments.
%   Ends: 1xMaxFragment (or less) end positions for fragments.
%
% Revisions:
% 2020-Sep-17   function was created

%% Generate random packet sizes
idx = randi([1 length(PossiblePacketSizes)],1,ceil(FileLength/min(PossiblePacketSizes)));
PacketSizes = PossiblePacketSizes(idx);

%% Discard all-empty or half-empty packets
Packet_Pos = cumsum([0 PacketSizes]);
j0 = find(Packet_Pos<=FileLength,1,'last');
Packet_Pos = Packet_Pos(1:j0);

%% Disregard BOF and EOF
Disregard_Length_BOF = FileLength*DisregardBOF;
Disregard_Length_EOF = FileLength*DisregardEOF;
Packet_Pos = Packet_Pos((Packet_Pos+1)>Disregard_Length_BOF & Packet_Pos<=(FileLength-Disregard_Length_EOF));

%% No fragments can be taken
NumCandidates = length(Packet_Pos)-1;
if NumCandidates<=0
    Starts = [];
    Ends = [];
    return;
end

%% Select randomly at most MaxFragment fragments
RndPacketIDX = randperm(NumCandidates);
RndPacketIDX = RndPacketIDX(1:min(length(RndPacketIDX),MaxFragment));
Starts = zeros(1,length(RndPacketIDX));
Ends = zeros(1,length(RndPacketIDX));

%% Take fragments
for j=1:length(RndPacketIDX)
    
    % Position of fragment in audio file
    Starts(j) = Packet_Pos(RndPacketIDX(j))+1;
    Ends(j) = Packet_Pos(RndPacketIDX(j)+1);
    
end

