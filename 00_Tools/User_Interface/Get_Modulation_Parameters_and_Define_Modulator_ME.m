% This function get the parameters for a modulation type and defines modulator structure.
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
% Inputs:
%   ModType: Modulation Type ('Digital' | 'Analog')
%   GetMultipleModulators: If true, the user can specify vectors for
%       parameters of modulator. In this case, multiple modulators are defined
%       and returned in the Mod array.
%
% Outputs:
%   Mod: Modulation structure
%       Note: For definition, see Initialize_Modulation_ME function.
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%
% Revisions:
% 2020-Sep-14   function was created
% 2020-Dec-22   The functionality of getting multiple modulators of the same kind with
%               different parameters is now possible.

function [Mod,ErrorMsg] = Get_Modulation_Parameters_and_Define_Modulator_ME(ModType,varargin)

global AnalogModTypes DigitalModTypes
Mod = [];

if nargin<2
    GetMultipleModulators = false;
else
    GetMultipleModulators = varargin{1};
end

if strcmpi (ModType,'Digital')
    
    % Determine Digital Modulation Type
    [ErrorMsg,Subsets,~] = Select_from_List_ME(DigitalModTypes,1,'Select Modulation Type',true);
    
    if ~isempty(ErrorMsg)
        return;
    end
    
    ModType = DigitalModTypes{Subsets{1}};
    
    % Get Modulation Parameters and Define Modulator
    switch ModType
        
        case 'msk'
            
            [success,sps,ini_phase,dfcTs] = PromptforParameters_ME(...
                {'Number of samples per symbol','Carrier initial phase of modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration'},...
                {'8','0','0'},...
                'MSK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for MSK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(ini_phase,2)*size(dfcTs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for ini_phase_i = ini_phase
                        for dfcTs_i = dfcTs
                            [Mod_i,~] = Initialize_Modulation_ME(ModType,'sps',sps_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i);
                            if ~isempty(Mod_i)
                                cnt = cnt+1;
                                if cnt==1
                                    Mod = Mod_i;
                                else
                                    Mod(cnt) = Mod_i;
                                end
                            end
                            curr_prg = curr_prg+1;
                            stopbar = progressbar_ME(1,curr_prg/total_prg);
                            if stopbar
                                Mod = [];
                                ErrorMsg = 'Process aborted by user.';
                                return;
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'sps',sps,'ini_phase',ini_phase,'dfcTs',dfcTs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'gmsk'
            
            [success,BT,sps,L,ini_phase,dfcTs] = PromptforParameters_ME(...
                {'The product of bandwidth and time','Number of samples per symbol','Pulse length (in symbol duration)','Carrier initial phase of modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration'},...
                {'0.3','8','4','0','0'},...
                'GMSK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for GMSK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(BT,2)*size(sps,2)*size(L,2)*size(ini_phase,2)*size(dfcTs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for BT_i = BT
                    for sps_i = sps
                        for L_i = L
                            for ini_phase_i = ini_phase
                                for dfcTs_i = dfcTs
                                    [Mod_i,~] = Initialize_Modulation_ME(ModType,'BT',BT_i,'sps',sps_i,'L',L_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i);
                                    if ~isempty(Mod_i)
                                        cnt = cnt+1;
                                        if cnt==1
                                            Mod = Mod_i;
                                        else
                                            Mod(cnt) = Mod_i;
                                        end
                                    end
                                    curr_prg = curr_prg+1;
                                    stopbar = progressbar_ME(1,curr_prg/total_prg);
                                    if stopbar
                                        Mod = [];
                                        ErrorMsg = 'Process aborted by user.';
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'BT',BT,'sps',sps,'L',L,'ini_phase',ini_phase,'dfcTs',dfcTs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
            
        case 'fsk'
            
            [success,M,sps,h,ini_phase,dfcTs,phase_cont,symbol_order] = PromptforParameters_ME(...
                {'Modulation order (2,4,8)','Number of samples per symbol','Modulation index (product of frequency seperation and symbol duration)','Carrier initial phase of Modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration','Phase continuity (discont|cont)','Symbol order (gray |bin)'},...
                {'2','8','1','0','0','cont','gray'},...
                'FSK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for FSK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(M,2)*size(sps,2)*size(h,2)*size(ini_phase,2)*size(dfcTs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for M_i = M
                    for sps_i = sps
                        for h_i = h
                            for ini_phase_i = ini_phase
                                for dfcTs_i = dfcTs
                                    [Mod_i,~] = Initialize_Modulation_ME(ModType,'M',M_i,'sps',sps_i,'h',h_i,'ini_phase',ini_phase_i,'phase_cont',phase_cont,'dfcTs',dfcTs_i,'symbol_order',symbol_order);
                                    if ~isempty(Mod_i)
                                        cnt = cnt+1;
                                        if cnt==1
                                            Mod = Mod_i;
                                        else
                                            Mod(cnt) = Mod_i;
                                        end
                                    end
                                    curr_prg = curr_prg+1;
                                    stopbar = progressbar_ME(1,curr_prg/total_prg);
                                    if stopbar
                                        Mod = [];
                                        ErrorMsg = 'Process aborted by user.';
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'M',M,'sps',sps,'h',h,'ini_phase',ini_phase,'phase_cont',phase_cont,'dfcTs',dfcTs,'symbol_order',symbol_order);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'psk'
            
            [success,M,phaserot,sps,ini_phase,dfcTs,beta,symbol_order] = PromptforParameters_ME(...
                {'Modulation order (2,4,8,16)','Phase rotation of the modulation in radians','Number of samples per symbol','Carrier initial phase of Modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration','Roll-off factor for root raised cosine pulse','Symbol order (gray|bin)'},...
                {'2','0','8','0','0','0.35','gray'},...
                'PSK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for PSK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(M,2)*size(sps,2)*size(phaserot,2)*size(ini_phase,2)*size(dfcTs,2)*size(beta,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for M_i = M
                    for sps_i = sps
                        for phaserot_i = phaserot
                            for ini_phase_i = ini_phase
                                for dfcTs_i = dfcTs
                                    for beta_i = beta
                                        [Mod_i,~] = Initialize_Modulation_ME(ModType,'M',M_i,'phaserot',phaserot_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i,'beta',beta_i,'symbol_order',symbol_order);
                                        if ~isempty(Mod_i)
                                            cnt = cnt+1;
                                            if cnt==1
                                                Mod = Mod_i;
                                            else
                                                Mod(cnt) = Mod_i;
                                            end
                                        end
                                        curr_prg = curr_prg+1;
                                        stopbar = progressbar_ME(1,curr_prg/total_prg);
                                        if stopbar
                                            Mod = [];
                                            ErrorMsg = 'Process aborted by user.';
                                            return;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'M',M,'phaserot',phaserot,'sps',sps,'ini_phase',ini_phase,'dfcTs',dfcTs,'beta',beta,'symbol_order',symbol_order);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'dpsk'
            
            [success,M,phaserot,sps,ini_phase,dfcTs,beta,symbol_order] = PromptforParameters_ME(...
                {'Modulation order (2,4,8,16)','Phase rotation of the modulation in radians','Number of samples per symbol','Carrier initial phase of Modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration','Roll-off factor for root raised cosine pulse','Symbol order (gray|bin)'},...
                {'2','0','8','0','0','0.35','gray'},...
                'DPSK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for DPSK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(M,2)*size(sps,2)*size(phaserot,2)*size(ini_phase,2)*size(dfcTs,2)*size(beta,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for M_i = M
                    for sps_i = sps
                        for phaserot_i = phaserot
                            for ini_phase_i = ini_phase
                                for dfcTs_i = dfcTs
                                    for beta_i = beta
                                        [Mod_i,~] = Initialize_Modulation_ME(ModType,'M',M_i,'phaserot',phaserot_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i,'beta',beta_i,'symbol_order',symbol_order);
                                        if ~isempty(Mod_i)
                                            cnt = cnt+1;
                                            if cnt==1
                                                Mod = Mod_i;
                                            else
                                                Mod(cnt) = Mod_i;
                                            end
                                        end
                                        curr_prg = curr_prg+1;
                                        stopbar = progressbar_ME(1,curr_prg/total_prg);
                                        if stopbar
                                            Mod = [];
                                            ErrorMsg = 'Process aborted by user.';
                                            return;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'M',M,'phaserot',phaserot,'sps',sps,'ini_phase',ini_phase,'dfcTs',dfcTs,'beta',beta,'symbol_order',symbol_order);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'oqpsk'
            
            [success,phaserot,sps,ini_phase,dfcTs,beta,symbol_order] = PromptforParameters_ME(...
                {'Phase rotation of the modulation in radians','Number of samples per symbol','Carrier initial phase of Modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration','Roll-off factor for root raised cosine pulse','Symbol order (gray|bin)'},...
                {'pi/4','8','0','0','0.35','gray'},...
                'OQPSK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for OQPSK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(phaserot,2)*size(ini_phase,2)*size(dfcTs,2)*size(beta,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for phaserot_i = phaserot
                        for ini_phase_i = ini_phase
                            for dfcTs_i = dfcTs
                                for beta_i = beta
                                    [Mod_i,~] = Initialize_Modulation_ME(ModType,'phaserot',phaserot_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i,'beta',beta_i,'symbol_order',symbol_order);
                                    if ~isempty(Mod_i)
                                        cnt = cnt+1;
                                        if cnt==1
                                            Mod = Mod_i;
                                        else
                                            Mod(cnt) = Mod_i;
                                        end
                                    end
                                    curr_prg = curr_prg+1;
                                    stopbar = progressbar_ME(1,curr_prg/total_prg);
                                    if stopbar
                                        Mod = [];
                                        ErrorMsg = 'Process aborted by user.';
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'phaserot',phaserot,'sps',sps,'ini_phase',ini_phase,'dfcTs',dfcTs,'beta',beta,'symbol_order',symbol_order);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'qam'
            
            [success,M,phaserot,sps,ini_phase,dfcTs,beta,symbol_order] = PromptforParameters_ME(...
                {'Modulation order (8,16,32,64,128)','Phase rotation of the modulation in radians','Number of samples per symbol','Carrier initial phase of Modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration','Roll-off factor for root raised cosine pulse','Symbol order (gray|bin)'},...
                {'16','0','8','0','0','0.35','gray'},...
                'QAM Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for QAM Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(M,2)*size(sps,2)*size(phaserot,2)*size(ini_phase,2)*size(dfcTs,2)*size(beta,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for M_i = M
                    for sps_i = sps
                        for phaserot_i = phaserot
                            for ini_phase_i = ini_phase
                                for dfcTs_i = dfcTs
                                    for beta_i = beta
                                        [Mod_i,~] = Initialize_Modulation_ME(ModType,'M',M_i,'phaserot',phaserot_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i,'beta',beta_i,'symbol_order',symbol_order);
                                        if ~isempty(Mod_i)
                                            cnt = cnt+1;
                                            if cnt==1
                                                Mod = Mod_i;
                                            else
                                                Mod(cnt) = Mod_i;
                                            end
                                        end
                                        curr_prg = curr_prg+1;
                                        stopbar = progressbar_ME(1,curr_prg/total_prg);
                                        if stopbar
                                            Mod = [];
                                            ErrorMsg = 'Process aborted by user.';
                                            return;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'M',M,'phaserot',phaserot,'sps',sps,'ini_phase',ini_phase,'dfcTs',dfcTs,'beta',beta,'symbol_order',symbol_order);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
            
        case 'ask'
            
            [success,M,phaserot,sps,ini_phase,dfcTs,beta,symbol_order] = PromptforParameters_ME(...
                {'Modulation order (4,8,16)','Phase rotation of the modulation in radians','Number of samples per symbol','Carrier initial phase of Modulator (in radians)','Product of carrier frequency deviation of modulator and symbol duration','Roll-off factor for root raised cosine pulse','Symbol order (gray|bin)'},...
                {'4','0','8','0','0','0.35','gray'},...
                'ASK Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for ASK Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(M,2)*size(sps,2)*size(phaserot,2)*size(ini_phase,2)*size(dfcTs,2)*size(beta,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for M_i = M
                    for sps_i = sps
                        for phaserot_i = phaserot
                            for ini_phase_i = ini_phase
                                for dfcTs_i = dfcTs
                                    for beta_i = beta
                                        [Mod_i,~] = Initialize_Modulation_ME(ModType,'M',M_i,'phaserot',phaserot_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfcTs',dfcTs_i,'beta',beta_i,'symbol_order',symbol_order);
                                        if ~isempty(Mod_i)
                                            cnt = cnt+1;
                                            if cnt==1
                                                Mod = Mod_i;
                                            else
                                                Mod(cnt) = Mod_i;
                                            end
                                        end
                                        curr_prg = curr_prg+1;
                                        stopbar = progressbar_ME(1,curr_prg/total_prg);
                                        if stopbar
                                            Mod = [];
                                            ErrorMsg = 'Process aborted by user.';
                                            return;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'M',M,'phaserot',phaserot,'sps',sps,'ini_phase',ini_phase,'dfcTs',dfcTs,'beta',beta,'symbol_order',symbol_order);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
    end
    
else
    
    % Determine Analog Modulation Type
    [ErrorMsg,Subsets,~] = Select_from_List_ME(AnalogModTypes,1,'Select Modulation Type',true);
    
    if ~isempty(ErrorMsg)
        return;
    end
    
    ModType = AnalogModTypes{Subsets{1}};
    
    % Get Modulation Parameters and Define Modulator
    switch ModType
        
        case 'am'
            
            [success,sps,ini_phase,dfc_div_fs,m] = PromptforParameters_ME(...
                {'Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate','Modulation index (peak value of message divided by carrier amplitude)'},...
                {'8','0','0','0.5'},...
                'AM Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for AM Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2)*size(m,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for ini_phase_i = ini_phase
                        for dfc_div_fs_i = dfc_div_fs
                            for m_i = m
                                [Mod_i,~] = Initialize_Modulation_ME(ModType,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i,'m',m_i);
                                if ~isempty(Mod_i)
                                    cnt = cnt+1;
                                    if cnt==1
                                        Mod = Mod_i;
                                    else
                                        Mod(cnt) = Mod_i;
                                    end
                                end
                                curr_prg = curr_prg+1;
                                stopbar = progressbar_ME(1,curr_prg/total_prg);
                                if stopbar
                                    Mod = [];
                                    ErrorMsg = 'Process aborted by user.';
                                    return;
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs,'m',m);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'dsb'
            
            [success,sps,ini_phase,dfc_div_fs] = PromptforParameters_ME(...
                {'Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate'},...
                {'8','0','0'},...
                'DSB Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for DSB Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for ini_phase_i = ini_phase
                        for dfc_div_fs_i = dfc_div_fs
                            [Mod_i,~] = Initialize_Modulation_ME(ModType,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i);
                            if ~isempty(Mod_i)
                                cnt = cnt+1;
                                if cnt==1
                                    Mod = Mod_i;
                                else
                                    Mod(cnt) = Mod_i;
                                end
                            end
                            curr_prg = curr_prg+1;
                            stopbar = progressbar_ME(1,curr_prg/total_prg);
                            if stopbar
                                Mod = [];
                                ErrorMsg = 'Process aborted by user.';
                                return;
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'usb'
            
            [success,sps,ini_phase,dfc_div_fs] = PromptforParameters_ME(...
                {'Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate'},...
                {'8','0','0'},...
                'USB Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for USB Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for ini_phase_i = ini_phase
                        for dfc_div_fs_i = dfc_div_fs
                            [Mod_i,~] = Initialize_Modulation_ME(ModType,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i);
                            if ~isempty(Mod_i)
                                cnt = cnt+1;
                                if cnt==1
                                    Mod = Mod_i;
                                else
                                    Mod(cnt) = Mod_i;
                                end
                            end
                            curr_prg = curr_prg+1;
                            stopbar = progressbar_ME(1,curr_prg/total_prg);
                            if stopbar
                                Mod = [];
                                ErrorMsg = 'Process aborted by user.';
                                return;
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'lsb'
            
            [success,sps,ini_phase,dfc_div_fs] = PromptforParameters_ME(...
                {'Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate'},...
                {'8','0','0'},...
                'LSB Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for LSB Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for ini_phase_i = ini_phase
                        for dfc_div_fs_i = dfc_div_fs
                            [Mod_i,~] = Initialize_Modulation_ME(ModType,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i);
                            if ~isempty(Mod_i)
                                cnt = cnt+1;
                                if cnt==1
                                    Mod = Mod_i;
                                else
                                    Mod(cnt) = Mod_i;
                                end
                            end
                            curr_prg = curr_prg+1;
                            stopbar = progressbar_ME(1,curr_prg/total_prg);
                            if stopbar
                                Mod = [];
                                ErrorMsg = 'Process aborted by user.';
                                return;
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'isb'
            
            [success,sps,ini_phase,dfc_div_fs] = PromptforParameters_ME(...
                {'Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate'},...
                {'8','0','0'},...
                'ISB Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for ISB Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for sps_i = sps
                    for ini_phase_i = ini_phase
                        for dfc_div_fs_i = dfc_div_fs
                            [Mod_i,~] = Initialize_Modulation_ME(ModType,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i);
                            if ~isempty(Mod_i)
                                cnt = cnt+1;
                                if cnt==1
                                    Mod = Mod_i;
                                else
                                    Mod(cnt) = Mod_i;
                                end
                            end
                            curr_prg = curr_prg+1;
                            stopbar = progressbar_ME(1,curr_prg/total_prg);
                            if stopbar
                                Mod = [];
                                ErrorMsg = 'Process aborted by user.';
                                return;
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'fm'
            
            [success,h,sps,ini_phase,dfc_div_fs] = PromptforParameters_ME(...
                {'Frequency deviation of modulator divided by input signal maximum frequency (i.e. h=Df/fm)','Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate'},...
                {'4','8','0','0'},...
                'FM Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for FM Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(h,2)*size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for h_i = h
                    for sps_i = sps
                        for ini_phase_i = ini_phase
                            for dfc_div_fs_i = dfc_div_fs
                                [Mod_i,~] = Initialize_Modulation_ME(ModType,'h',h_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i);
                                if ~isempty(Mod_i)
                                    cnt = cnt+1;
                                    if cnt==1
                                        Mod = Mod_i;
                                    else
                                        Mod(cnt) = Mod_i;
                                    end
                                end
                                curr_prg = curr_prg+1;
                                stopbar = progressbar_ME(1,curr_prg/total_prg);
                                if stopbar
                                    Mod = [];
                                    ErrorMsg = 'Process aborted by user.';
                                    return;
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'h',h,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
            
        case 'pm'
            
            [success,h,sps,ini_phase,dfc_div_fs] = PromptforParameters_ME(...
                {'Frequency deviation of modulator divided by input signal maximum frequency (i.e. h=Df/fm)','Number of output signal samples corresponding to each input sample','Carrier initial phase in radians','Carrier frequency deviation of modulator divided by sampling rate'},...
                {'4','8','0','0'},...
                'PM Modulation Parameters');
            if ~success
                ErrorMsg = 'Parameters for PM Modulation were not provided.';
                return;
            end
            
            if GetMultipleModulators
                total_prg = size(h,2)*size(sps,2)*size(ini_phase,2)*size(dfc_div_fs,2);
                curr_prg = 0;
                cnt = 0;
                progressbar_ME('Building Modulators ...');
                for h_i = h
                    for sps_i = sps
                        for ini_phase_i = ini_phase
                            for dfc_div_fs_i = dfc_div_fs
                                [Mod_i,~] = Initialize_Modulation_ME(ModType,'h',h_i,'sps',sps_i,'ini_phase',ini_phase_i,'dfc_div_fs',dfc_div_fs_i);
                                if ~isempty(Mod_i)
                                    cnt = cnt+1;
                                    if cnt==1
                                        Mod = Mod_i;
                                    else
                                        Mod(cnt) = Mod_i;
                                    end
                                end
                                curr_prg = curr_prg+1;
                                stopbar = progressbar_ME(1,curr_prg/total_prg);
                                if stopbar
                                    Mod = [];
                                    ErrorMsg = 'Process aborted by user.';
                                    return;
                                end
                            end
                        end
                    end
                end
                progressbar_ME(1,1);
            else
                [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,'h',h,'sps',sps,'ini_phase',ini_phase,'dfc_div_fs',dfc_div_fs);
                if ~isempty(ErrorMsg)
                    return;
                end
            end
    end
end

if GetMultipleModulators
    if cnt==0
        ErrorMsg = 'No mudulator can be built.';
        return;
    end
    
    choice = questdlg(sprintf('%d out of %d modulators are built successfully. Do you want to continue?',cnt,total_prg),'Result of Building Modulators','Yes','No','Yes');
    if ~isequal(choice,'Yes')
        Mod = [];
        ErrorMsg = 'Process aborted by user.';
        return;
    end
end