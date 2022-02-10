% This function initializes the structure for a specific modulation.
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
%   ModType: Modulation type
%       Digital Modulations: 'msk', 'gmsk', 'fsk', 'psk', 'dpsk', 'oqpsk', 'qam', 'ask'
%       Analog Modulations: 'am', 'dsb', 'usb', 'lsb', 'isb', 'fm', 'pm'
%   varargin: 2xL input arguments that can be used to assign non-default values to some fields.
%       For i=1,2,3,...,L, varargin{2*i-1} is the desired field name and
%       varargin{2*i} is the desired field value.
%
% Output:
%   Mod: Modulation structure
%   ErrorMsg: Possible error message
%
% Revisions:
% 2020-Sep-01   function was created
% 2020-Dec-21   fractional sps functionality was added

function [Mod,ErrorMsg] = Initialize_Modulation_ME(ModType,varargin)

switch lower(ModType)
    
    case 'msk'
        
        % M: Modulation order (fixed value: 2)
        % sps: Number of samples per symbol (default: 8)
        % ini_phase: Carrier initial phase of modulator (in radians, default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        Mod = Define_Structure_ME({'Type','M','sps','ini_phase','dfcTs'},...
            {'msk',2,8,0,0},...
            varargin);
        
        % Check: M is 2
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for MSK modulation','fixed-value',2);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for MSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for MSK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and 1.5+2*abs(dfcTs)<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for MSK modulation','type','scalar','class','real',...
            'min',1.5+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
    case 'gmsk'
        
        % M: Modulation order (fixed value 2)
        % BT: The product of bandwidth and time (default: 0.3)
        % sps: Number of samples per symbol (default: 8)
        % L: Pulse length (in symbol duration, default: 4)
        % ini_phase: Carrier initial phase of modulator (in radians, default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        Mod = Define_Structure_ME({'Type','M','BT','sps','L','ini_phase','dfcTs'},...
            {'gmsk',2,0.3,8,4,0,0},...
            varargin);
        
        % Check: M is 2
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for GMSK modulation','fixed-value',2);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: BT is real scalar and 0.1<=BT<=0.9
        ErrorMsg = Check_Variable_Value_ME(Mod.BT,'BT (the product of bandwidth and time) for GMSK modulation','type','scalar','class','real',...
            'min',0.1,'max',0.9);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: L is even integer value and 2<=L<=10
        ErrorMsg = Check_Variable_Value_ME(Mod.L,'Pulse length for GMSK modulation','type','scalar','class','real',...
            'class','integer','min',2,'max',10,'mod',[2 0]);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for GMSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for GMSK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar, 1.5+2*abs(dfcTs)<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for GMSK modulation','type','scalar','class','real',...
            'min',1.5+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Modulator Filter
        sps_int = ceil(Mod.sps);
        delta = sqrt(log(2))/(2*pi*Mod.BT);
        half_span = Mod.L/2*sps_int;
        t = (-half_span:half_span)/sps_int;
        h = 1/(sqrt(2*pi)*delta)*exp(-t.^2/(2*delta.^2));
        if mod(sps_int,2)==0
            rect = ones(1,sps_int+1);
            delay = half_span+sps_int/2;
        else
            rect = ones(1,sps_int);
            delay = half_span+(sps_int-1)/2;
        end
        g = conv(h,rect);
        g = g(1+delay+(-half_span:half_span));
        g = g/sum(g);
        G = cumsum(g);
        Mod.PulseShaping.g = g;
        Mod.PulseShaping.delay = half_span;
        Mod.PulseShaping.alpha = flipud(vec2mat(G(1:end-1),sps_int));
        
    case 'fsk'
        
        % M: Modulation order (2 (default), 4, or 8)
        % sps: samples per symbol (default: 8)
        % h: Modulation index that is the product of frequency seperation and symbol duration (h>=1, default is 1)
        % ini_phase: Carrier initial phase (default: 0)
        % phase_cont: Phase continuity ('discont' | 'cont' (default))
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        % symbol_order: Symbol order ('gray' (default) | 'bin')
        
        Mod = Define_Structure_ME({'Type','M','sps','h','ini_phase','phase_cont','dfcTs','symbol_order'},...
            {'fsk',2,8,1,0,'cont',0,'gray'},...
            varargin);
        
        % Check: M is even integer value from {2, 4, 8}
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for FSK modulation','possiblevalues',{2,4,8});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: h is real scalar and h>=1
        ErrorMsg = Check_Variable_Value_ME(Mod.h,'Modulation index h (product of frequency seperation and baud rate) for FSK modulation','type','scalar',...
            'class','real','min',1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for FSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: phase_cont is 'discont' or 'cont'
        ErrorMsg = Check_Variable_Value_ME(Mod.phase_cont,'Phase continuity for FSK modulation','possiblevalues',{'discont','cont'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for FSK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: symbol_order is 'gray' or 'bin'
        ErrorMsg = Check_Variable_Value_ME(Mod.symbol_order,'Symbol order for FSK modulation','possiblevalues',{'gray','bin'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and 1+2*(h*(M-1)/2+abs(dfcTs))<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for FSK modulation','type','scalar','class','real',...
            'min',1+2*(abs(Mod.dfcTs)+((Mod.M-1)/2)*Mod.h),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Symbol Mapping
        if strcmpi(Mod.symbol_order,'gray') % Gray encode and decode
            Mod.Txsymbolmap = bin2gray_ME('fsk',Mod.M); % Transmitter
            Mod.Rxsymbolmap = gray2bin_ME('fsk',Mod.M); % Reciever
        else
            Mod.Txsymbolmap = (0:Mod.M-1);
            Mod.Rxsymbolmap = (0:Mod.M-1);
        end
        
    case 'psk'
        
        % M: Modulation order (2 (default), 4, 8, 16)
        % phaserot: phase rotation of the modulation in radians (default: 0)
        % sps: samples per symbol (default: 8)
        % ini_phase: Carrier initial phase (default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        % beta: Roll-off factor for root raised cosine pulse (default: 0.35)
        % symbol_order: Symbol order ('gray' (default) | 'bin')
        
        Mod = Define_Structure_ME({'Type','M','phaserot','sps','ini_phase','dfcTs','beta','symbol_order'},...
            {'psk',2,0,8,0,0,0.35,'gray'},...
            varargin);
        
        % Check: M is even integer value from {2, 4, 8, 16}
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for PSK modulation','possiblevalues',{2,4,8,16});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: phaserot is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.phaserot,'phase rotation for PSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for PSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for PSK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: beta is real scalar and 0<=beta<=1
        ErrorMsg = Check_Variable_Value_ME(Mod.beta,'beta (roll-off factor) for PSK modulation','type','scalar',...
            'class','real','min',0,'max',1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: symbol_order is 'gray' or 'bin'
        ErrorMsg = Check_Variable_Value_ME(Mod.symbol_order,'Symbol order for PSK modulation','possiblevalues',{'gray','bin'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and (1+beta+2*abs(dfcTs))<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for PSK modulation','type','scalar','class','real',...
            'min',1+Mod.beta+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Symbol Mapping
        if strcmpi(Mod.symbol_order,'gray') % Gray encode and decode
            Mod.Txsymbolmap = bin2gray_ME('psk',Mod.M); % Transmitter
            Mod.Rxsymbolmap = gray2bin_ME('psk',Mod.M); % Reciever
        else
            Mod.Txsymbolmap = (0:Mod.M-1);
            Mod.Rxsymbolmap = (0:Mod.M-1);
        end
        
        % Pulse Shaping
        sps_int = ceil(Mod.sps);
        Mod.PulseShaping.h = rcosdesign_ME(Mod.beta,8,sps_int,'sqrt'); % pulse shaping filter
        Mod.PulseShaping.delay = (length(Mod.PulseShaping.h)-1)/2; % filter delay (in samples)
        Mod.PulseShaping.half_symbol = round(sps_int/2); % half symbol time (in samples)
        
    case 'dpsk'
        
        % M: Modulation order (2 (default), 4, 8, 16)
        % phaserot: phase rotation of the modulation in radians (default: 0)
        % sps: samples per symbol (default: 8)
        % ini_phase: Carrier initial phase (default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        % beta: Roll-off factor for root raised cosine pulse (default: 0.35)
        % symbol_order: Symbol order ('gray' (default) | 'bin')
        
        Mod = Define_Structure_ME({'Type','M','phaserot','sps','ini_phase','dfcTs','beta','symbol_order'},...
            {'dpsk',2,0,8,0,0,0.35,'gray'},...
            varargin);
        
        % Check: M is even integer value from {2, 4, 8, 16}
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for DPSK modulation','possiblevalues',{2,4,8,16});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: phaserot is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.phaserot,'phase rotation for DPSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for DPSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for DPSK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: beta is real scalar and 0<=beta<=1
        ErrorMsg = Check_Variable_Value_ME(Mod.beta,'beta (roll-off factor) for DPSK modulation','type','scalar',...
            'class','real','min',0,'max',1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: symbol_order is 'gray' or 'bin'
        ErrorMsg = Check_Variable_Value_ME(Mod.symbol_order,'Symbol order for DPSK modulation','possiblevalues',{'gray','bin'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and (1+beta+2*abs(dfcTs))<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for DPSK modulation','type','scalar','class','real',...
            'min',1+Mod.beta+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Symbol Mapping
        if strcmpi(Mod.symbol_order,'gray') % Gray encode and decode
            Mod.Txsymbolmap = bin2gray_ME('dpsk',Mod.M); % Transmitter
            Mod.Rxsymbolmap = gray2bin_ME('dpsk',Mod.M); % Reciever
        else
            Mod.Txsymbolmap = (0:Mod.M-1);
            Mod.Rxsymbolmap = (0:Mod.M-1);
        end
        
        % Pulse Shaping
        sps_int = ceil(Mod.sps);
        Mod.PulseShaping.h = rcosdesign_ME(Mod.beta,8,sps_int,'sqrt'); % pulse shaping filter
        Mod.PulseShaping.delay = (length(Mod.PulseShaping.h)-1)/2; % filter delay (in samples)
        Mod.PulseShaping.half_symbol = round(sps_int/2); % half symbol time (in samples)
        
    case 'oqpsk'
        
        % M: Modulation order (fixed value 4)
        % phaserot: phase rotation of the modulation in radians (default: 0)
        % sps: samples per symbol (default: 8)
        % ini_phase: Carrier initial phase (default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        % beta: Roll-off factor for root raised cosine pulse (default: 0.35)
        % symbol_order: Symbol order ('gray' (default) | 'bin')
        
        Mod = Define_Structure_ME({'Type','M','phaserot','sps','ini_phase','dfcTs','beta','symbol_order'},...
            {'oqpsk',4,0,8,0,0,0.35,'gray'},...
            varargin);
        
        % Check: M is 4
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for OQPSK modulation','fixed-value',4);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: phaserot is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.phaserot,'phase rotation for OQPSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for OQPSK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for OQPSK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: beta is real scalar and 0<=beta<=1
        ErrorMsg = Check_Variable_Value_ME(Mod.beta,'beta (roll-off factor) for OQPSK modulation','type','scalar',...
            'class','real','min',0,'max',1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: symbol_order is 'gray' or 'bin'
        ErrorMsg = Check_Variable_Value_ME(Mod.symbol_order,'Symbol order for OQPSK modulation','possiblevalues',{'gray','bin'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and (1+beta+2*abs(dfcTs))<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for OQPSK modulation','type','scalar','class','real',...
            'min',1+Mod.beta+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Symbol Mapping
        if strcmpi(Mod.symbol_order,'gray') % Gray encode and decode
            Mod.Txsymbolmap = bin2gray_ME('oqpsk',Mod.M); % Transmitter
            Mod.Rxsymbolmap = gray2bin_ME('oqpsk',Mod.M); % Reciever
        else
            Mod.Txsymbolmap = (0:Mod.M-1);
            Mod.Rxsymbolmap = (0:Mod.M-1);
        end
        
        % Pulse Shaping
        sps_int = ceil(Mod.sps);
        Mod.PulseShaping.h = rcosdesign_ME(Mod.beta,8,sps_int,'sqrt'); % pulse shaping filter
        Mod.PulseShaping.delay = (length(Mod.PulseShaping.h)-1)/2; % filter delay (in samples)
        Mod.PulseShaping.half_symbol = round(sps_int/2); % half symbol time (in samples)
        
    case 'qam'
        
        % M: Modulation order (8, 16 (default), 32, 64, 128)
        % phaserot: phase rotation of the modulation in radians (default: 0)
        % sps: samples per symbol (default: 8)
        % ini_phase: Carrier initial phase (default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        % beta: Roll-off factor for root raised cosine pulse (default: 0.35)
        % symbol_order: Symbol order ('gray' (default) | 'bin')
        
        Mod = Define_Structure_ME({'Type','M','phaserot','sps','ini_phase','dfcTs','beta','symbol_order'},...
            {'qam',16,0,8,0,0,0.35,'gray'},...
            varargin);
        
        % Check: M is even integer value from {8, 16, 32, 64, 128}
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for QAM modulation','possiblevalues',{8,16,32,64,128});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: phaserot is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.phaserot,'phase rotation for QAM modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for QAM modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for QAM modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: beta is real scalar and 0<=beta<=1
        ErrorMsg = Check_Variable_Value_ME(Mod.beta,'beta (roll-off factor) for QAM modulation','type','scalar',...
            'class','real','min',0,'max',1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: symbol_order is 'gray' or 'bin'
        ErrorMsg = Check_Variable_Value_ME(Mod.symbol_order,'Symbol order for QAM modulation','possiblevalues',{'gray','bin'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and (1+beta+2*abs(dfcTs))<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for QAM modulation','type','scalar','class','real',...
            'min',1+Mod.beta+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Symbol Mapping
        if strcmpi(Mod.symbol_order,'gray') % Gray encode and decode
            Mod.Txsymbolmap = bin2gray_ME('qam',Mod.M); % Transmitter
            Mod.Rxsymbolmap = gray2bin_ME('qam',Mod.M); % Reciever
        else
            Mod.Txsymbolmap = (0:Mod.M-1);
            Mod.Rxsymbolmap = (0:Mod.M-1);
        end
        
        % Pulse Shaping
        sps_int = ceil(Mod.sps);
        Mod.PulseShaping.h = rcosdesign_ME(Mod.beta,8,sps_int,'sqrt'); % pulse shaping filter
        Mod.PulseShaping.delay = (length(Mod.PulseShaping.h)-1)/2; % filter delay (in samples)
        Mod.PulseShaping.half_symbol = round(sps_int/2); % half symbol time (in samples)
        
    case 'ask'
        
        % M: Modulation order (4(default), 8, 16)
        % phaserot: phase rotation of the modulation in radians (default: 0)
        % sps: samples per symbol (default: 8)
        % ini_phase: Carrier initial phase (default: 0)
        % dfcTs: Product of carrier frequency deviation of modulator and symbol duration (default: 0)
        % beta: Roll-off factor for root raised cosine pulse (default: 0.35)
        % symbol_order: Symbol order ('gray' (default) | 'bin')
        
        Mod = Define_Structure_ME({'Type','M','phaserot','sps','ini_phase','dfcTs','beta','symbol_order'},...
            {'ask',4,0,8,0,0,0.35,'gray'},...
            varargin);
        
        % Check: M is even integer value from {4, 8, 16}
        ErrorMsg = Check_Variable_Value_ME(Mod.M,'M (modulation order) for ASK modulation','possiblevalues',{4,8,16});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: phaserot is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.phaserot,'phase rotation for ASK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for ASK modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfcTs is real scalar and abs(dfcTs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfcTs,'dfcTs (product of carrier frequency deviation of modulator and symbol duration) for ASK modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: beta is real scalar and 0<=beta<=1
        ErrorMsg = Check_Variable_Value_ME(Mod.beta,'beta (roll-off factor) for ASK modulation','type','scalar',...
            'class','real','min',0,'max',1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: symbol_order is 'gray' or 'bin'
        ErrorMsg = Check_Variable_Value_ME(Mod.symbol_order,'Symbol order for ASK modulation','possiblevalues',{'gray','bin'});
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and (1+beta+2*abs(dfcTs))<=sps<=32
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'Number of samples per symbol for ASK modulation','type','scalar','class','real',...
            'min',1+Mod.beta+2*abs(Mod.dfcTs),'max',32);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Symbol Mapping
        if strcmpi(Mod.symbol_order,'gray') % Gray encode and decode
            Mod.Txsymbolmap = bin2gray_ME('ask',Mod.M); % Transmitter
            Mod.Rxsymbolmap = gray2bin_ME('ask',Mod.M); % Reciever
        else
            Mod.Txsymbolmap = (0:Mod.M-1);
            Mod.Rxsymbolmap = (0:Mod.M-1);
        end
        
        % Pulse Shaping
        sps_int = ceil(Mod.sps);
        Mod.PulseShaping.h = rcosdesign_ME(Mod.beta,8,sps_int,'sqrt'); % pulse shaping filter
        Mod.PulseShaping.delay = (length(Mod.PulseShaping.h)-1)/2; % filter delay (in samples)
        Mod.PulseShaping.half_symbol = round(sps_int/2); % half symbol time (in samples)
        
    case 'am'
        
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by sampling rate (default: 0)
        % m: Modulation index that is peak value of message divided by carrier amplitude (default: 0.5)
        %   Note: if m>1, then overmodulation occurs.
        
        Mod = Define_Structure_ME({'Type','sps','ini_phase','dfc_div_fs','m'},...
            {'am',8,0,0,0.5},...
            varargin);
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for AM modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (Carrier frequency deviation of modulator divided by sampling rate) for AM modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and sps>=1/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for AM modulation','type','scalar',...
            'class','real','min',1/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: modulation index m is real scalar and m>0
        ErrorMsg = Check_Variable_Value_ME(Mod.m,'Modulation index for AM modulation','type','scalar',...
            'class','real','min',eps);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
    case 'dsb'
        
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by sampling rate (default: 0)
        
        Mod = Define_Structure_ME({'Type','sps','ini_phase','dfc_div_fs',},...
            {'dsb',8,0,0},...
            varargin);
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for DSB modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (Carrier frequency deviation of modulator divided by sampling rate) for DSB modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: sps is real scalar and sps>=1/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for DSB modulation','type','scalar',...
            'class','real','min',1/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        
    case 'usb'
        
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by sampling rate (default: 0)
        
        Mod = Define_Structure_ME({'Type','sps','ini_phase','dfc_div_fs',},...
            {'usb',8,0,0},...
            varargin);
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for USB modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (Carrier frequency deviation of modulator divided by sampling rate) for USB modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end

        % Check: sps is real scalar and sps>=1/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for USB modulation','type','scalar',...
            'class','real','min',1/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
    case 'lsb'
        
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by sampling rate (default: 0)
        
        Mod = Define_Structure_ME({'Type','sps','ini_phase','dfc_div_fs',},...
            {'lsb',8,0,0},...
            varargin);
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for LSB modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (Carrier frequency deviation of modulator divided by sampling rate) for LSB modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end

        % Check: sps is real scalar and sps>=1/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for LSB modulation','type','scalar',...
            'class','real','min',1/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
    case 'isb'
        
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by sampling rate (default: 0)
        
        Mod = Define_Structure_ME({'Type','sps','ini_phase','dfc_div_fs',},...
            {'isb',8,0,0},...
            varargin);
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for ISB modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (Carrier frequency deviation of modulator divided by sampling rate) for ISB modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end

        % Check: sps is real scalar and sps>=1/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for ISB modulation','type','scalar',...
            'class','real','min',1/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
    case 'fm'
        
        % h: Frequency deviation of modulator (denoted by Df) divided by input signal maximum frequency (denoted by fm) (default: 4)
        %   Note 1: h is called modulation index.
        %   Note 2: Input signal maximum frequency is assumed to be equal to half
        %       the sampling rate of the provided input audio signal (denoted by Fs); i.e. fm = Fs/2.
        %   Note 3: Baseband FM bandwidth is equal to Df+fm = (1+h)*Fs/2, so the
        %       minimum sampling frequency should be fs>=(1+h)*Fs.
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by output signal sampling rate (default: 0)
        %   Note 4: When dfc_div_fs~=0, minimum sampling frequency should be fs>=(1+h)/(1-2*dfc_div_fs)*Fs.

        Mod = Define_Structure_ME({'Type','h','sps','ini_phase','dfc_div_fs',},...
            {'fm',4,8,0,0},...
            varargin);
        
        % Check: h is real scalar and 0.1<=h<=10
        ErrorMsg = Check_Variable_Value_ME(Mod.h,'Modulation index h (frequency deviation of modulator divided by input signal maximum frequency) for FM modulation','type','scalar',...
            'class','real','min',0.1,'max',10);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (carrier frequency deviation of modulator divided by sampling rate) for FM modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end        
        
        % Check: sps is real scalar and sps>=(1+h)/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for FM modulation','type','scalar',...
            'class','real','min',(1+Mod.h)/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for FM modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
    case 'pm'
        
        % h: Frequency deviation of modulator (denoted by Df) divided by input signal maximum frequency (denoted by fm) (default: 4)
        %   Note 1: h is called modulation index.
        %   Note 2: Input signal maximum frequency is assumed to be equal to half
        %       the sampling rate of the provided input audio signal (denoted by Fs); i.e. fm = Fs/2.
        %   Note 3: Baseband PM bandwidth is equal to Df+fm = (1+h)*Fs/2, so the
        %       minimum sampling frequency should be fs>=(1+h)*Fs.
        % sps: Number of output signal samples corresponding to each input sample (i.e. fs/Fs; default: 8)
        % ini_phase: Carrier initial phase in radians (default: 0)
        % dfc_div_fs: Carrier frequency deviation of modulator divided by output signal sampling rate (default: 0)
        %   Note 4: When dfc_div_fs~=0, minimum sampling frequency should be fs>=(1+h)/(1-2*dfc_div_fs)*Fs.

        Mod = Define_Structure_ME({'Type','h','sps','ini_phase','dfc_div_fs',},...
            {'pm',4,8,0,0},...
            varargin);
        
        % Check: h is real scalar and 0.1<=h<=10
        ErrorMsg = Check_Variable_Value_ME(Mod.h,'Modulation index h (frequency deviation of modulator divided by input signal maximum frequency) for PM modulation','type','scalar',...
            'class','real','min',0.1,'max',10);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: dfc_div_fs is real scalar and abs(dfc_div_fs)<=0.1
        ErrorMsg = Check_Variable_Value_ME(Mod.dfc_div_fs,'dfc_div_fs (carrier frequency deviation of modulator divided by sampling rate) for PM modulation','type','scalar',...
            'class','real','min',-0.1,'max',0.1);
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end        
        
        % Check: sps is real scalar and sps>=(1+h)/(1-2*dfc_div_fs)
        ErrorMsg = Check_Variable_Value_ME(Mod.sps,'sps (number of output signal samples corresponding to each input sample) for PM modulation','type','scalar',...
            'class','real','min',(1+Mod.h)/(1-2*Mod.dfc_div_fs));
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
        % Check: ini_phase is real scalar
        ErrorMsg = Check_Variable_Value_ME(Mod.ini_phase,'Carrier initial phase of modulator for PM modulation','type','scalar','class','real');
        if ~isempty(ErrorMsg)
            Mod = [];
            return;
        end
        
end