function ErrorMsg = Script_GenerateDataset_from_BurstsDataset_ME

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
%   (2) Generates Dataset of extracted features that includes
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
%   variable Dataset_ME, ClassLabels_ME, FeatureLabels_ME.
%   Three more variables Function_Handles,Function_Labels, and
%   Function_Select are also saved.
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
% 2020-Sep-21   function was created

%% Select Feature Types
FeatureTypes = {'Spectral-based Features',...
    'Wavelet Transform-based Features',...
    'High-order Cumulant-based Features',...
    'Cyclostationary Analysis-based Features',...
    'High-order Moment-based Features',...
    'Amplitudes Histogram',...
    };

[ErrorMsg,Subsets,~] = Select_from_List_ME(FeatureTypes,1,'Select feature types to be included:',false);
if ~isempty(ErrorMsg)
    return;
end

FeatureTypes = FeatureTypes(Subsets{1});

%% Get Necessary Parameters for Feature Calculation
Param_Names = {};
Param_Description = {};
Default_Value = {};

% Define default parameter for Spectral-based Features
if any(strcmp(FeatureTypes,'Spectral-based Features'))
    Param_Names = [Param_Names 'At'];
    Param_Description = [Param_Description 'Thresould for detemining low-amplitude samples (non-negative scalar)'];
    Default_Value = [Default_Value '0.5'];
end

% Define default parameter for Wavelet Transform-based Features
if any(strcmp(FeatureTypes,'Wavelet Transform-based Features'))
    Param_Names = [Param_Names 'T' 'k'];
    Param_Description = [Param_Description 'Wavelet Scales (vector with values from 2~32)' 'Maximum Order of Moments for Wavelet Transform-based Features (2~5)'];
    Default_Value = [Default_Value '2:16' '5'];
end

% Define default parameter for High-order Cumulant-based Features
if any(strcmp(FeatureTypes,'High-order Cumulant-based Features'))
    Param_Names = [Param_Names 'Nfft'];
    Param_Description = [Param_Description 'Number of FFT points in preprocessing steps of High-order Cumulant-based Features (128~4096)'];
    Default_Value = [Default_Value '1024'];
end

% Define default parameter for Cyclostationary Analysis-based Features
if any(strcmp(FeatureTypes,'Cyclostationary Analysis-based Features'))
    Param_Names = [Param_Names 'N' 'L'];
    Param_Description = [Param_Description 'Number of FFT points (N) in Cyclostationary Analysis-based Features (32~1024)' ...
        'Length of moving average filter in Cyclostationary Analysis-based Features (1~0.1*N)'];
    Default_Value = [Default_Value '512' '20'];
end

% Define default parameter for High-order Moment-based Features
if any(strcmp(FeatureTypes,'High-order Moment-based Features'))
    Param_Names = [Param_Names 'm' 'n'];
    Param_Description = [Param_Description 'Different values of m for E(x^{m-n)}*conj(x^n)) in High-order Moment-based Features (2~10)' ...
        'Different values of n for E(x^{m-n}*conj(x^n)) in High-order Moment-based Features (0~m-1)'];
    Default_Value = [Default_Value '[2 2 3 3 3 4 4 4 4]' '[1 0 2 1 0 3 2 1 0]'];
end

% Define default parameter for Amplitudes Histogram Features
if any(strcmp(FeatureTypes,'Amplitudes Histogram'))
    Param_Names = [Param_Names 'M'];
    Param_Description = [Param_Description 'Number of bins in Amplitudes Histogram (16~256)'];
    Default_Value = [Default_Value '128'];
end

% Write specific command using PromptforParameters_ME to get parameters
if ~isempty(Param_Names)
    dlg_title = 'Parameters for feature extraction functions';
    str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title);
    eval(str_cmd);
    
    if ~success
        ErrorMsg = 'Process is aborted. Feature extraction parameters was not provided.';
        return;
    end
    
end

%% Check Parameters for Feature Calculation
% Check parameter for Spectral-based Features
if any(strcmp(FeatureTypes,'Spectral-based Features'))
    
    ErrorMsg = Check_Variable_Value_ME(At,'At value for Spectral-based Features','type','scalar','class','real','min',0);
    if ~isempty(ErrorMsg)
        return;
    end
    
end

% Check parameter for Wavelet Transform-based Features
if any(strcmp(FeatureTypes,'Wavelet Transform-based Features'))
    
    ErrorMsg = Check_Variable_Value_ME(T,'Wavelet Scales','type','vector','class','real','class','integer','min',2,'max',32);
    if ~isempty(ErrorMsg)
        return;
    end
    
    ErrorMsg = Check_Variable_Value_ME(k,'Maximum Order of Moments for Wavelet Transform-based Features',...
        'type','scalar','class','real','class','integer','min',2,'max',5);
    if ~isempty(ErrorMsg)
        return;
    end
    
end

% Check parameter for High-order Cumulant-based Features
if any(strcmp(FeatureTypes,'High-order Cumulant-based Features'))
    
    ErrorMsg = Check_Variable_Value_ME(Nfft,'Number of FFT points in preprocessing steps of High-order Cumulant-based Features',...
        'type','scalar','class','real','class','integer','min',128,'max',4096);
    if ~isempty(ErrorMsg)
        return;
    end
    
end

% Check parameter for Cyclostationary Analysis-based Features
if any(strcmp(FeatureTypes,'Cyclostationary Analysis-based Features'))

    ErrorMsg = Check_Variable_Value_ME(N,'Number of FFT points (N) in Cyclostationary Analysis-based Features',...
        'type','scalar','class','real','class','integer','min',32,'max',1024);
    if ~isempty(ErrorMsg)
        return;
    end

    ErrorMsg = Check_Variable_Value_ME(L,'Length of moving average filter in Cyclostationary Analysis-based Features',...
        'type','scalar','class','real','class','integer','min',1,'max',0.1*N);
    if ~isempty(ErrorMsg)
        return;
    end
    
end

% Check parameter for High-order Moment-based Features
if any(strcmp(FeatureTypes,'High-order Moment-based Features'))
    
    ErrorMsg = Check_Variable_Value_ME(m,'Different values of m for E(x^(m-n)*conj(x^n)) in High-order Moment-based Features',...
        'type','vector','class','real','class','integer','min',2,'max',10);
    if ~isempty(ErrorMsg)
        return;
    end
    
    ErrorMsg = Check_Variable_Value_ME(n,'Different values of n for E(x^(m-n)*conj(x^n)) in High-order Moment-based Features',...
        'type','vector','class','real','class','integer','size',size(m),'min',0);
    if ~isempty(ErrorMsg)
        return;
    end
    
    ErrorMsg = Check_Variable_Value_ME(m-n,'Different values of m-n for E(x^(m-n)*conj(x^n)) in High-order Moment-based Features',...
        'type','vector','class','real','class','integer','min',1);
    if ~isempty(ErrorMsg)
        return;
    end
    
end

% Check parameter for Amplitudes Histogram Features
if any(strcmp(FeatureTypes,'Amplitudes Histogram'))
    
    ErrorMsg = Check_Variable_Value_ME(M,'Number of bins in Amplitudes Histogram',...
        'type','scalar','class','real','class','integer','min',16,'max',256);
    if ~isempty(ErrorMsg)
        return;
    end
    
end

%% Define Features Extraction Functions
NumFeatExtFunc = 0; % Number of features extraction functions

% Initialization
Function_Handles = cell(1,NumFeatExtFunc);
Function_Labels = cell(1,NumFeatExtFunc);
cnt = 0;

% Define functions and their outputs
if any(strcmp(FeatureTypes,'Spectral-based Features'))
    cnt = cnt+1;
    Function_Handles{cnt} = @(x) SpectralBasedFeatures_ME(x,At); % Function of feature extraction

    At_str = sprintf('_%g',At);
    At_str(At_str=='.') = '_';
    Function_Labels{cnt} = {'gamma_max',['sigma_ap' At_str],['sigma_dp' At_str],'P','sigma_aa',['sigma_af' At_str],['sigma_a' At_str],'mu42_a','mu42_f'};
end

if any(strcmp(FeatureTypes,'Wavelet Transform-based Features'))
    cnt = cnt+1;
    Function_Handles{cnt} = @(x) WaveletTransformBasedFeatures_ME(x,T,k); % Function of feature extraction
    Function_Labels{cnt} = cell(1,k*4*length(T));
    WT_strs = {'WT','WT_med','WTn','WTn_med'};
    lablel_cnt = 0;
    for i = T
        for str_cnt = 1:length(WT_strs)
            for j = 1:k
                lablel_cnt = lablel_cnt+1;
                Function_Labels{cnt}{lablel_cnt} = [WT_strs{str_cnt} sprintf('_M_%d_T_%d',j,i)];
            end
         end
    end
end

if any(strcmp(FeatureTypes,'High-order Cumulant-based Features'))
    cnt = cnt+1;
    Function_Handles{cnt} = @(x) HighOrderCumulantBasedFeatures_ME(x,Nfft); % Function of feature extraction
    Function_Labels{cnt} = {'abs_C20' 'abs_C40' 'abs_C41' 'abs_C42' 'angle_C20' 'angle_C40' 'angle_C41' 'angle_C42'};
end

if any(strcmp(FeatureTypes,'Cyclostationary Analysis-based Features'))
    cnt = cnt+1;
    Function_Handles{cnt} = @(x) CyclostationaryAnalysisBasedFeatures_ME(x,N,L); % Function of feature extraction
    Function_Labels{cnt} = cell(1,ceil(N/2));
    for j=1:ceil(N/2)
        Function_Labels{cnt}{j} = sprintf('SCF_N_%d_L_%d_%d',N,L,j);
    end
    
end

if any(strcmp(FeatureTypes,'High-order Moment-based Features'))
    for j=1:length(m)
        cnt = cnt+1;
        Function_Handles{cnt} = @(x) HighOrderSignalMoments_ME(x,m(j),n(j)); % Function of feature extraction
        Function_Labels{cnt} = {sprintf('mu_x_%d_%d',m(j),n(j))};
    end
end

if any(strcmp(FeatureTypes,'Amplitudes Histogram'))
    cnt = cnt+1;
    Function_Handles{cnt} = @(x) AmplitudeHistograms_ME(x,M); % Function of feature extraction
    Function_Labels{cnt} = cell(1,M);
    for j=1:M
        Function_Labels{cnt}{j} = sprintf('AmpHist_%d_%d',M,j);
    end
end

NumFeatExtFunc = cnt;
if NumFeatExtFunc==0
    ErrorMsg = 'Process is aborted. No feature is extracted.';
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
F_idx = zeros(1,NumFeatExtFunc+1);
for cnt=1:NumFeatExtFunc
    F_idx(cnt+1) = F_idx(cnt)+length(Function_Labels{cnt});
end

FeatureLabels = cell(1,F_idx(end));
for cnt=1:NumFeatExtFunc
    FeatureLabels(F_idx(cnt)+1:F_idx(cnt+1)) = Function_Labels{cnt};
end
NumberofFeatures = length(FeatureLabels); % Number of Features

if NumFeatExtFunc==0
    ErrorMsg = 'Process is aborted. The number of features is equal to zero.';
    return;
end

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
        for cnt=1:NumFeatExtFunc
            Dataset(BurstCnt,F_idx(cnt)+1:F_idx(cnt+1)) = Function_Handles{cnt}(x);
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

%% Save Dataset
Function_Select = cell(1,length(Function_Labels));
for j=1:length(Function_Labels)
    Function_Select{j} = true(1,length(Function_Labels{j}));
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','-v7.3');

%% Update GUI
GUI_Dataset_Update_ME(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select);
GUI_MainEditBox_Update_ME(false,'The process of feature extraction from bursts is completed successfully.');