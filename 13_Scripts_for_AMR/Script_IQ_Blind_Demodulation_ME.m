function ErrorMsg = Script_IQ_Blind_Demodulation_ME

% This script blindly demodulates a modulated I/Q signal.
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
global Demodulated_IQ_PushButton_ME
global iq_information_ME
global iq_param_estimation
global demodulated_iq_ME
global RxPrms

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Initialization
RxPrms = [];
RxPrms.sps = iq_param_estimation.T;
RxPrms.BR = iq_param_estimation.BaudRate;

%% Get Modulation Type
switch iq_param_estimation.TargetModType
    
    case 'Linear Modulation with root-raised-cosine (RRC) pulse shaping'
        
        LinearModTypes = {'psk','qam','dpsk','oqpsk'};
        [ErrorMsg,Subsets,~] = Select_from_List_ME(LinearModTypes,1,'Select Modulation Type',true);
        if ~isempty(ErrorMsg)
            return;
        end
        RxPrms.ModType = LinearModTypes{Subsets{1}};
        
        % Set Default Parameters
        RxPrms.shape = 'sqrt'; % Shape of raised cosine window ('sqrt' | 'normal')
        RxPrms.span = 6; % Number of symbols in raise cosine window
        RxPrms.beta = 1; % Unknown roll-off factor
        RxPrms.T2 = round(RxPrms.sps/2);
        RxPrms.h = rcosdesign_fr_ME(RxPrms.beta,RxPrms.span,RxPrms.sps,RxPrms.shape); % pulse shaping filter
        RxPrms.D = (length(RxPrms.h)-1)/2;

        switch RxPrms.ModType
            
            case 'psk'
                Possible_M_values = {2,4,8};
                
            case 'dpsk'
                Possible_M_values = {2,4};

            case 'qam'
                Possible_M_values = {8,16,32,64,128};
                                
            case 'oqpsk'
                Possible_M_values = {4};
                
        end
        
    case 'FSK Modulation'
        
        RxPrms.ModType = 'fsk';
        Possible_M_values = {2,4,8};
        
end

%% Get Main Parameters of Modulation
switch RxPrms.ModType
    
    case 'psk'
        
        M_str = num2str(cell2mat(Possible_M_values),'%d,');
        
        Param_Names = {'RxPrms.M','RxPrms.phaserot','RxPrms.symbol_order','ConvergenceDelay'};
        Param_Description = {sprintf('Modulation order M (%s)',M_str(1:end-1)),...
            'Phase Rotation in Radians (0 | pi/M)',...
            'Symbol Order (gray|bin)',...
            sprintf('Convergence Delay of Blind Demodulation in Symbols (0~%d)',floor(0.5*length(iq_information_ME.Content)/RxPrms.sps))};
        Default_Value = {num2str(Possible_M_values{1}),'0','gray',num2str(min(1000,floor(0.5*length(iq_information_ME.Content)/RxPrms.sps)))};
    
    case 'dpsk'
        
        M_str = num2str(cell2mat(Possible_M_values),'%d,');
        
        Param_Names = {'RxPrms.M','RxPrms.phaserot','RxPrms.symbol_order','ConvergenceDelay'};
        Param_Description = {sprintf('Modulation order M (%s)',M_str(1:end-1)),...
            'Phase Rotation in Radians (0 | pi/4)',...
            'Symbol Order (gray|bin)',...
            sprintf('Convergence Delay of Blind Demodulation in Symbols (0~%d)',floor(0.5*length(iq_information_ME.Content)/RxPrms.sps))};
        Default_Value = {num2str(Possible_M_values{1}),'0','gray',num2str(min(1000,floor(0.5*length(iq_information_ME.Content)/RxPrms.sps)))};
    
    case 'qam'
        
        M_str = num2str(cell2mat(Possible_M_values),'%d,');
        RxPrms.phaserot = 0;
        
        Param_Names = {'RxPrms.M','RxPrms.symbol_order','ConvergenceDelay'};
        Param_Description = {sprintf('Modulation order M (%s)',M_str(1:end-1)),...
            'Symbol Order (gray|bin)',...
            sprintf('Convergence Delay of Blind Demodulation in Symbols (0~%d)',floor(0.5*length(iq_information_ME.Content)/RxPrms.sps))};
        Default_Value = {num2str(Possible_M_values{1}),'gray',num2str(min(1000,floor(0.5*length(iq_information_ME.Content)/RxPrms.sps)))};
        
    case 'oqpsk'
        
        RxPrms.M = 4;
        RxPrms.phaserot = pi/4;
        
        Param_Names = {'RxPrms.symbol_order','ConvergenceDelay'};
        Param_Description = {'Symbol Order (gray|bin)',...
            sprintf('Convergence Delay of Blind Demodulation in Symbols (0~%d)',floor(0.5*length(iq_information_ME.Content)/RxPrms.sps))};
        Default_Value = {'gray',num2str(min(1000,floor(0.5*length(iq_information_ME.Content)/RxPrms.sps)))};        
        
    case 'fsk'
        
        RxPrms.M = iq_param_estimation.M;
        RxPrms.freqs = iq_param_estimation.freqs;
        RxPrms.T2 = iq_param_estimation.T2;
        RxPrms.fs = iq_information_ME.fs;

        Param_Names = {'RxPrms.symbol_order'};
        Param_Description = {'Symbol Order (gray|bin)'};
        Default_Value = {'gray'};                
end

dlg_title = 'Main Parameters of Modulation';
str_cmd = PromptforParameters_text_for_eval_ME(Param_Names,Param_Description,Default_Value,dlg_title);
eval(str_cmd);

if ~success
    ErrorMsg = 'Analysis parameters were not provided.';
    return;
end

%% Check Main Parameters of Modulation

% Check: M is integer value from Possible_M_values
ErrorMsg = Check_Variable_Value_ME(RxPrms.M,'Modulation order','possiblevalues',Possible_M_values);
if ~isempty(ErrorMsg)
    return;
end

% Check: phaserot is real scalar
if isfield(RxPrms,'phaserot')
    if strcmpi(RxPrms.ModType,'psk')
        ErrorMsg = Check_Variable_Value_ME(RxPrms.phaserot,'Phase rotation','possiblevalues',{0,pi/RxPrms.M});
        if ~isempty(ErrorMsg)
            return;
        end        
    elseif strcmpi(RxPrms.ModType,'dpsk')
        ErrorMsg = Check_Variable_Value_ME(RxPrms.phaserot,'Phase rotation','possiblevalues',{0,pi/4});
        if ~isempty(ErrorMsg)
            return;
        end
    end
end

%% Preprocessing
ErrorMsg = '';
r = iq_information_ME.Content;

%% Receiever Parameters Setup
switch lower(RxPrms.ModType)
    
    case {'psk','oqpsk','dpsk'}
        
        RxPrms.Constellation = exp(1i*(RxPrms.phaserot+2*pi*(0:RxPrms.M-1)/RxPrms.M)); % Constellation points
        
    case 'qam'
        
        RxPrms.Constellation = qam_constellation_ME(RxPrms.M); % Constellation points
        
end

if isequal(RxPrms.symbol_order,'gray')
    RxPrms.symbolmap = gray2bin_ME(RxPrms.ModType,RxPrms.M);
else
    RxPrms.symbolmap = (0:RxPrms.M-1);
end

%% Synchronization and Demodulation
switch RxPrms.ModType
    
    case {'psk','qam','dpsk'}
        
        r = r/sqrt(mean(abs(r).^2)); % Normalize signal
        r = r.*exp(-1i*2*pi*iq_param_estimation.df/iq_information_ME.fs*(1:length(r))); % Frequency offset compensation
        
        [s_hat,v_hat,possible_phasertos] = QAM_PSK_Receiver_ME(r,ConvergenceDelay,true);
        
    case 'oqpsk'
        
        r = r/sqrt(mean(abs(r).^2)); % Normalize signal
        r = r.*exp(-1i*2*pi*iq_param_estimation.df/iq_information_ME.fs*(1:length(r))); % Frequency offset compensation
        
        [s_hat,~,v_hat1,v_hat2,possible_phasertos] = OQPSK_Receiver_ME(r,ConvergenceDelay,true);
        L0 = min(size(v_hat1,2),size(v_hat2,2));
        v_hat = [v_hat1(:,1:L0) ; v_hat2(:,1:L0)];
        possible_phasertos = [possible_phasertos possible_phasertos];
        
    case 'fsk'
        
        % Fine Baud-rate estimation
        h = figure;
        set(h,'Name',sprintf('Results of Blind Demodulation'),'NumberTitle','off');
        if RxPrms.M==2
            [~,~,TimingError] = FSK_Receiver_ME(r,RxPrms.freqs);
            
            RxPrms.sps = FSK_FineBaudRateEstimation_ME(TimingError,RxPrms.sps);
            RxPrms.BR = RxPrms.fs/RxPrms.sps;
            
            subplot(2,1,1)
            plot(cumsum(TimingError))
            title('Timing Error Before Fine Baud-Rate Estimation')
            xlabel('Symbol')
            ylabel('Error (samples)')
            subplot(2,1,2)
        end
        
        % Synchronization and Demodulation
        [s_hat,v_hat,TimingError] = FSK_Receiver_ME(r,RxPrms.freqs);
        plot(cumsum(TimingError))
        title('Timing Error in Demodulation')
        xlabel('Symbol')
        ylabel('Error (samples)')
        possible_phasertos = 0;

end

demodulated_iq_ME.Type = 'Digital';
demodulated_iq_ME.Constellation = s_hat;
demodulated_iq_ME.Content = v_hat;
demodulated_iq_ME.possible_phasertos = possible_phasertos;
demodulated_iq_ME.BitRate = (iq_information_ME.fs/iq_param_estimation.T)*log2(RxPrms.M);

%% Enable Next Box in AMR Block
Demodulated_IQ_PushButton_ME.BackgroundColor = [0 1 0];
Demodulated_IQ_PushButton_ME.Enable = 'on';
