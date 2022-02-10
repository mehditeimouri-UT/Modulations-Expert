function ErrorMsg = Script_Present_Demodulated_Information_ME

% This function presents demodulated information in ones of the
% following ways:
%   (I) Power Spectral Density
%   (II) Play on Speaker
%   (III) Calculate BER (bit error rate)
%   (IV) Show Constellation
%   (V) Signal Information
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
% 2020-Sep-14   function was created

%% Initialization
global message_ME demodulated_message_ME

%% Determine Presentation Type
if strcmpi(demodulated_message_ME.Type,'Analog')
    Menus = {'Power Spectral Density','Play on Speaker','Data Information'};
else 
    if strcmpi(message_ME.Type,'Digital')
        Menus = {'Calculate BER','Data Information'};
    else
        Menus = {'Data Information'};
    end    
end

if isfield(demodulated_message_ME,'Constellation')
    Menus{end+1} = 'Show Constellation';
end

[ErrorMsg,Subsets,~] = Select_from_List_ME(Menus,1,...
    'Select Presentation Type for Demodulated Data',true);
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
        
        ErrorMsg = Plot_PSD_ME(demodulated_message_ME.Content,demodulated_message_ME.Fs);
        if ~isempty(ErrorMsg)
            return;
        end
        
    case 'Play on Speaker'
        
        if demodulated_message_ME.Fs<80 || demodulated_message_ME.Fs>1e6
            ErrorMsg = 'Sample rate, in hertz, of audio data should be between 80 and 1000000.';
            return;
        end        
        sound(demodulated_message_ME.Content',demodulated_message_ME.Fs);
        
    case 'Data Information'
        
        Display_Sturcture_Info_ME(demodulated_message_ME,'Demodulated Information');
        
    case 'Calculate BER'
        
        % Calculate BER
        [dt,L,numerr,BER] = Calculate_BER_ME(message_ME.Content,demodulated_message_ME.Content);
        
        % Display Results
        Msg = {sprintf('Demodulated Data Delay = %d',dt),...
            sprintf('Total Overlap Between Input and Output = %d',L),...
            sprintf('Total Number of Errors = %d',numerr),...
            sprintf('BER = %g',BER)};
        helpdlg(Msg,'BER Calculation Results');
        
    case 'Show Constellation'
        
        figure('Name','Signal Constellation','NumberTitle','off','WindowStyle','normal');
        plot(complex(demodulated_message_ME.Constellation),'.');
        title('Demodulator Output Constellation');       
        
end
