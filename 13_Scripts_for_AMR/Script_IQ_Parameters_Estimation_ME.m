function ErrorMsg = Script_IQ_Parameters_Estimation_ME

% This scripts estimates the modulator parameters from a modulated I/Q data.
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
% 2020-Dec-10   function was created

%% Initialization
global IQ_Blind_Demodulator_PushButton_ME
global iq_information_ME
global iq_param_estimation
global IQ_EstimationResults_Text_ME
global Demodulated_IQ_PushButton_ME

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Check Data Length
MinLength = 4096;
L = length(iq_information_ME.Content);
if L<MinLength
    ErrorMsg = Sprintf('Data Length should be at least equal to %d.',MinLength);
    return;
end

%% Determine Target Modulation Type
TargetModTypes = {'Linear Modulation with root-raised-cosine (RRC) pulse shaping','FSK Modulation'};
[ErrorMsg,Subsets,~] = Select_from_List_ME(TargetModTypes,1,'Select Modulation Type before Parameters Estimation',true);
if ~isempty(ErrorMsg)
    return;
end
TargetModType = TargetModTypes{Subsets{1}};

%% Get Parameters
Nfft = min(4096,L); % Number of FFT points in analysis
MinFFT = 128;
D = floor(Nfft/2); % Overlap in analysis windowsParam_Names = {'i','j','Nfft','D'};

Param_Names = {'s','e','Nfft','D'};
Param_Description = {sprintf('Start Sample'),...
    sprintf('End Sample (<=%d); Note: End-Start+1 should be at least %d',L,MinLength),...
    sprintf('Number of FFT points (Nfft) in analysis (>=%d)',MinFFT),...
    sprintf('Overlap in analysis windows (0~Nfft-1)')};
Default_Value = {'1',num2str(L),num2str(Nfft),num2str(D)};

if strcmpi(TargetModType,'FSK Modulation')
    Param_Names{end+1} = 'RegularFSK';
    Param_Description{end+1} = 'false | true (baud rate is equal to frequency seperation)';
    Default_Value{end+1} = 'true';

    Param_Names{end+1} = 'M';
    Param_Description{end+1} = 'Modulation Order (2,4,8)';
    Default_Value{end+1} = '2';
    Possible_M_values = {2,4,8};

end

dlg_title = 'Parameters for Analysis';
str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title);
eval(str_cmd);

if ~success
    ErrorMsg = 'Analysis parameters were not provided.';
    return;
end

% Check: Start and End are integer scalars and End-Start+1 is
ErrorMsg = Check_Variable_Value_ME(s,'Start of Data','type','scalar',...
    'class','real','class','integer','min',1,'max',L);
if ~isempty(ErrorMsg)
    return;
end

ErrorMsg = Check_Variable_Value_ME(e,'End of Data','type','scalar',...
    'class','real','class','integer','min',1,'max',L);
if ~isempty(ErrorMsg)
    return;
end

ErrorMsg = Check_Variable_Value_ME(e-s+1,'Data Length','type','scalar',...
    'class','real','class','integer','min',MinLength);
if ~isempty(ErrorMsg)
    return;
end

% Check: Nfft is integer scalar and MinFFT<=Nfft<=(e-s+1)
ErrorMsg = Check_Variable_Value_ME(Nfft,'Number of FFT Points','type','scalar','class','real',...
    'class','integer','min',MinFFT,'max',e-s+1);
if ~isempty(ErrorMsg)
    return;
end

% Check: Overlap D is integer scalar and 0<=D<Nfft
ErrorMsg = Check_Variable_Value_ME(D,'Overlap in Windows','type','scalar','class','real',...
    'class','integer','min',0,'max',Nfft-1);
if ~isempty(ErrorMsg)
    return;
end

% Check: RegularFSK is true or false
if exist('RegularFSK','var')
    ErrorMsg = Check_Variable_Value_ME(RegularFSK,'RegularFSK flag','possiblevalues',{true false});
    if ~isempty(ErrorMsg)
        return;
    end
end

% Check: M is possible
if exist('M','var')
    ErrorMsg = Check_Variable_Value_ME(M,'Modulation order','possiblevalues',Possible_M_values);
    if ~isempty(ErrorMsg)
        return;
    end
end

%% Parameter Estimation
iq_param_estimation = [];
iq_param_estimation.TargetModType = TargetModType;
switch TargetModType
    
    case 'Linear Modulation with root-raised-cosine (RRC) pulse shaping'
        
        [Rs_hat,df] = QAM_PSK_BaudRateEstimation_ME(iq_information_ME.Content(s:e),iq_information_ME.fs,Nfft,D);
        T = iq_information_ME.fs/Rs_hat;
        iq_param_estimation.df = df;
        iq_param_estimation.T = T;
        iq_param_estimation.BaudRate = Rs_hat;
        
    case 'FSK Modulation'
        
        % Baud-Rate and Tone Frequencies Estimation
        if RegularFSK
            [Rs_hat,freqs] = FSK_BaudRateFreqsEstimation_ME(iq_information_ME.Content(s:e),iq_information_ME.fs,Nfft,D,M);
        else
            Rs_hat = FSK_BaudRateEstimation_ME(iq_information_ME.Content(s:e),iq_information_ME.fs,Nfft,D,M);
            [~,freqs] = FSK_BaudRateFreqsEstimation_ME(iq_information_ME.Content(s:e),iq_information_ME.fs,Nfft,D,M);
        end
        
        if isempty(freqs) || isempty(Rs_hat)
            ErrorMsg ='Problem in Baud-Rate and Tone Frequencies Estimation';
            IQ_Blind_Demodulator_PushButton_ME.Enable = 'off';
            return;
        end
        
        T = iq_information_ME.fs/Rs_hat;
        iq_param_estimation.BaudRate = Rs_hat;
        iq_param_estimation.T = T;
        iq_param_estimation.T2 = iq_param_estimation.T/2;
        iq_param_estimation.M = M;
        iq_param_estimation.freqs = freqs;
        
end

%% Enable Next Box in AMR Block
switch TargetModType
    
    case 'Linear Modulation with root-raised-cosine (RRC) pulse shaping'
        
        IQ_EstimationResults_Text_ME.String = sprintf('Symbol Duration (in Samples) = %g\n\nFrequency Offset (Hz) = %g',T,df);
        IQ_Blind_Demodulator_PushButton_ME.Enable = 'on';
        
    case 'FSK Modulation'
        
        freqs_str = num2str(freqs,'%g,');
        IQ_EstimationResults_Text_ME.String = sprintf('Symbol Duration (in Samples) = %g\n\nFrequencies (Hz) = [%s]',T,freqs_str(1:end-1));
        IQ_Blind_Demodulator_PushButton_ME.Enable = 'on';
end

Demodulated_IQ_PushButton_ME.BackgroundColor = [1 1 1];
Demodulated_IQ_PushButton_ME.Enable = 'off';