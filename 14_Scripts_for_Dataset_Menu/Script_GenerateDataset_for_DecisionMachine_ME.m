function ErrorMsg = Script_GenerateDataset_for_DecisionMachine_ME

% This function takes some datasets of bursts in binary data format (with 'FFFFFFF0' header)
% and does the following:
%
%   (1) Reads the Bursts
%
%   Note: The employed binary file format is a generic binary data format with *.dat extension.
%   The information about bursts are written consecutively as folows:
%       8 bytes for file ID written in ieee big-endian uint64 format
%       8 bytes for burst length (denote by L, in samples) written in ieee big-endian uint64 format
%       8 bytes for sampling frequency  written in ieee big-endian double format
%       L*8 bytes for real part of burst samples written in ieee big-endian double format
%       L*8 bytes for imaginary part of burst samples written in ieee big-endian double format
%
%   (2) Generates Dataset of extracted features for a specific decision machine trained/loaded in Modulations-Expert.
%       This Dataset includes
%           Dataset: Dataset with NumberofBursts rows (NumberofBursts samples corresponding to NumberofBursts bursts)
%               and C columns. The first NumberofFeatures = C-2 columns correspond to features.
%               The last two columns correspond to the integer-valued class labels
%               and the FileID of the bursts, respectively.
%           FeatureLabels: 1xNumberofFeatures cell. Cell contents are strings denoting the name of
%               features corresponding to the columns of Dataset.
%           ClassLabels: 1xNumberofClasses cell. Cell contents are strings denoting the name of
%               classes corresponding to integer-valued class labels 1,2,....
%
%           Note: Dataset rows are sorted as follows: First, the samples of
%           class 1 (corresponding to the first data file) appear.
%           Second, the the samples of class 2 appear, and so on.
%           Also for the samples of each class, the bursts with similar file
%           identifier appear consecutively.
%
%   (3) Saves Dataset and assigns the corresponding value to global
%   variable DM_Dataset_ME, DM_ClassLabels_ME, DM_FeatureLabels_ME.
%
% Copyright (C) 2021 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
% 2020-Sep-24   function was created
% 2021-Jan-03   DM_Feature_Transfrom_ME was included

%% Global Variables
global DecisionMachine_ME DecisionMachine_CL_ME DM_FeatureLabels_ME
global DM_Function_Handles_ME DM_Function_Labels_ME DM_Function_Select_ME
global DM_Feature_Transfrom_ME

%% Check that Decision Machine is generated/loaded
ErrorMsg = '';
if isempty(DecisionMachine_ME) && isempty(DecisionMachine_CL_ME)
    ErrorMsg = 'No decision machine is loaded. Please train or load a decision machine.';
    return;
end

if isempty(DM_Function_Handles_ME)
    ErrorMsg = 'The process is not possible: The decision machine does not include any function handle.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Get the name of the binary files for reading bursts
[FileName,PathName] = uigetfile('*.dat','Select Bursts Datasets in Generic Binary File Format','MultiSelect', 'on');
if isequal(FileName,0)
    ErrorMsg = 'Process is aborted. No Bursts Datasets in Generic Binary File Format was selected.';
    return;
end

if ischar(FileName)
    FileName = {FileName};
end

%% Determine Number of Bursts
TotalFiles = length(FileName);
FileisEmpty = false(1,TotalFiles);
ClassLabels = cell(1,TotalFiles);
NumberofClassMembers = zeros(1,TotalFiles);
progressbar_ME('Counting number of bursts ...');
for j=1:TotalFiles
    
    % Open file
    fileID = fopen([PathName FileName{j}],'r');
    
    
    % File Header
    header = fread(fileID,8,'char*1=>char',0,'b');
    header = header';
    if ~strcmp(header,'FFFFFFF0')
        
        FileisEmpty(j) = true;
        
        % Close file
        fclose(fileID);
        
        % Progress
        stopbar = progressbar_ME(1,j/TotalFiles);
        if stopbar
            ErrorMsg = 'Process is aborteded by user.';
            return;
        end
        
        continue;
    end
    
    % Set default class name and number of elements
    str = FileName{j};
    str(strfind(lower(str), '.dat'):end) = [];
    ClassLabels{j} = str;
    NumberofClassMembers(j) = 0; % Number of Bursts
    
    % Determine Number of Bursts in Class
    while(true)
        
        fread(fileID,(1),'uint64=>double',0,'b'); % File Identifier
        if feof(fileID)
            break;
        end
        
        L = fread(fileID,(1),'uint64=>double',0,'b'); % Burst Length
        fseek(fileID,(2*L+1)*(8),'cof'); % Skip Burst
        NumberofClassMembers(j) = NumberofClassMembers(j)+1;
        
    end
    
    % Close file
    fclose(fileID);
    
    % Progress
    stopbar = progressbar_ME(1,j/TotalFiles);
    if stopbar
        ErrorMsg = 'Process is aborteded by user.';
        fclose(fileID);
        return;
    end
    
end

%% Determine Number of Classes
NumberofClassMembers(FileisEmpty) = [];
ClassLabels(FileisEmpty) = [];
NumberofBursts = sum(NumberofClassMembers);
FileName(FileisEmpty) = [];

if NumberofBursts==0
    ErrorMsg = 'There is no burst for processing. The process is aborted.';
    return;
end

%% Set valid variable names for class labels
ClassLabels = SetVariableNames_ME(ClassLabels);

%% Get the Name of the File for Saving Dataset
[Filename,path] = uiputfile('mydataset.mat','Save Generated Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end

%% Determine Number of Features and Classes
FeatureLabels = DM_FeatureLabels_ME;
Function_Handles = DM_Function_Handles_ME;
Function_Labels = DM_Function_Labels_ME;
Function_Select = DM_Function_Select_ME;
Feature_Transfrom = DM_Feature_Transfrom_ME;
NumberofFeatures = sum(cell2mat(DM_Function_Select_ME));
NumberofClasses = length(ClassLabels);

%% Generate Dataset
% The last-1 and the last columns are class label and FileID, respectively
Dataset = zeros(NumberofBursts,NumberofFeatures+2);

progressbar_ME('Processing the bursts ...');
BurstCnt = 0;
for j=1:NumberofClasses
    
    % Open file
    fileID = fopen([PathName FileName{j}],'r');
        
    % Skip File Header
    fseek(fileID,8,'cof');
    
    while(true)
        
        file_identifier = fread(fileID,(1),'uint64=>double',0,'b'); % File Identifier
        if feof(fileID)
            break;
        end
        
        % Read Burst
        L = fread(fileID,(1),'uint64=>double',0,'b'); % Burst Length
        fs = fread(fileID,(1),'double',0,'b'); % Sampling Frequency
        xr = fread(fileID,(L),'double',0,'b'); % Real Part
        xi = fread(fileID,(L),'double',0,'b'); % Imaginary Part
        x = complex(xr',xi');        
        BurstCnt = BurstCnt+1;
        
        % Calculate Features
        f_cnt = 0;
        for cnt = 1:length(Function_Handles)
            if any(Function_Select{cnt})
                tmp = Function_Handles{cnt}(x);
                f_sum = sum(Function_Select{cnt});
                Dataset(BurstCnt,f_cnt+(1:f_sum)) = tmp(Function_Select{cnt});
                f_cnt = f_cnt+f_sum;
            end
        end
        Dataset(BurstCnt,end-1) = j;
        Dataset(BurstCnt,end) = file_identifier;
        
        if any(isnan(Dataset(BurstCnt,:)))
            ErrorMsg = sprintf('Process is aborted. The feature set for Burst-%d contains NaN.',BurstCnt);
            fclose(fileID);            
            return;
        end        
        
        
        % Progress
        stopbar = progressbar_ME(1,BurstCnt/NumberofBursts);
        if stopbar
            ErrorMsg = 'Process is aborteded by user.';
            fclose(fileID);
            return;
        end
        
    end
    
    % Close file
    fclose(fileID);    
    
end

%% Transform Dataset if needed
if ~isempty(Feature_Transfrom)
    Dataset = [Dataset(:,1:end-2)*Feature_Transfrom.Coef Dataset(:,end-1:end)];
end

%% Save Dataset
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_ME(false,'The process of feature extraction from bursts is completed successfully.');