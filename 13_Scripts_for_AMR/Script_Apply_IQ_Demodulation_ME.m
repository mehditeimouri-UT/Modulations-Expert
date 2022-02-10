function Script_Apply_IQ_Demodulation_ME

% This function applies the defined demodulator on I/Q information. 
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
% Revisions:
% 2020-Sep-16   function was created

%% Initialization
global AnalogModTypes DigitalModTypes LinearDigitalModTypes
global Demodulated_IQ_PushButton_ME
global iq_information_ME iq_demodulator_ME demodulated_iq_ME

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Apply Demodulator
demodulated_iq_ME = [];
switch iq_demodulator_ME.Type
    case DigitalModTypes
        demodulated_iq_ME.Type = 'Digital';
    case AnalogModTypes
        demodulated_iq_ME.Type = 'Analog';
end

switch iq_demodulator_ME.Type
    case LinearDigitalModTypes
        
        [demodulated_iq_ME.Content,demodulated_iq_ME.Constellation] = perform_demodulation_ME(iq_demodulator_ME,iq_information_ME.Content);
        
    otherwise
        
        demodulated_iq_ME.Content = perform_demodulation_ME(iq_demodulator_ME,iq_information_ME.Content);
end

if strcmpi(demodulated_iq_ME.Type,'Digital')
    demodulated_iq_ME.BitRate = (iq_information_ME.fs/iq_demodulator_ME.sps)*log2(iq_demodulator_ME.M);
else
    demodulated_iq_ME.Fs = iq_information_ME.fs/iq_demodulator_ME.sps;
end

%% Enable Next Box in AMR Block
Demodulated_IQ_PushButton_ME.BackgroundColor = [0 1 0];
Demodulated_IQ_PushButton_ME.Enable = 'on';