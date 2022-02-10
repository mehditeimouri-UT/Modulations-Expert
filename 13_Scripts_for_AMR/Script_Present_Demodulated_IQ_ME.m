function ErrorMsg = Script_Present_Demodulated_IQ_ME

% This function presents demodulated I/Q in ones of the
% following ways:
%   (I) Power Spectral Density
%   (II) Play on Speaker
%   (III) Show Constellation
%   (IV) Signal Information
%
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
% 2020-Sep-16   function was created

%% Initialization
global demodulated_iq_ME
global message_ME

%% Determine Presentation Type
if strcmpi(demodulated_iq_ME.Type,'Analog')
    Menus = {'Power Spectral Density','Play on Speaker','Data Information'};
else 
    if isfield(demodulated_iq_ME,'Constellation')
        Menus = {'Show Constellation','Data Information'};
    else
        Menus = {'Data Information'};
    end
    
    if ~isempty(message_ME)
        if strcmpi(message_ME.Type,'Digital')
            Menus{end+1} = 'Calculate BER (Compared to the Message in Modem)';
        end
    end    
end

[ErrorMsg,Subsets,~] = Select_from_List_ME(Menus,1,...
    'Select Presentation Type for Demodulated I/Q',true);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Perform Operation
switch Menus{Subsets{1}}
    
    case 'Power Spectral Density'
        
        ErrorMsg = Plot_PSD_ME(demodulated_iq_ME.Content,demodulated_iq_ME.Fs);
        if ~isempty(ErrorMsg)
            return;
        end
        
    case 'Play on Speaker'
        
        if demodulated_iq_ME.Fs<80 || demodulated_iq_ME.Fs>1e6
            ErrorMsg = 'Sample rate, in hertz, of audio data should be between 80 and 1000000.';
            return;
        end
        
        sound(demodulated_iq_ME.Content',demodulated_iq_ME.Fs);
        
    case 'Data Information'
        
        Display_Sturcture_Info_ME(demodulated_iq_ME,'Demodulated I/Q Information');
        
    case 'Show Constellation'
        
        figure('Name','Signal Constellation','NumberTitle','off','WindowStyle','normal');
        plot(complex(demodulated_iq_ME.Constellation),'.');
        title('Demodulator Output Constellation'); 
        
    case 'Calculate BER (Compared to the Message in Modem)'
        
        BER = inf;
        L = 0;
        numerr = 0;
        dt = 0;
        idx = 0;
        for j=1:size(demodulated_iq_ME.Content,1)
            [dt0,L0,numerr0,BER0] = Calculate_BER_ME(demodulated_iq_ME.Content(j,:),message_ME.Content);
            if BER0<BER
                BER = BER0;
                L = L0;
                numerr = numerr0;
                dt = dt0;
                idx = j;
            end
        end
        if idx==1
            phase_rot = 0;
        else
            phase_rot = round(demodulated_iq_ME.possible_phasertos(idx)*180/pi);
        end
        
        if phase_rot~=0
            msg_str = sprintf('Time offset = %d\n%d degrees of phase rotation\nCommon Length = %d\nNumber of Differences = %d\n\n\nBER = %g',dt,phase_rot,L,numerr,BER);
        else
            msg_str = sprintf('Time offset = %d\nCommon Length = %d\nNumber of Differences = %d\n\n\nBER = %g',dt,L,numerr,BER);
        end
        msgbox(msg_str,'BER','help','modal')
        
end
