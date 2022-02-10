function ErrorMsg = Script_Present_Unmodulated_Information_ME

% This function presents unmodulated information in ones of the
% following ways:
%   (I) Power Spectral Density
%   (II) Play on Speaker
%   (III) Signal Information
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
% 2020-Sep-13   function was created

%% Initialization
global message_ME

%% Determine Presentation Type
if strcmpi(message_ME.Type,'Analog')
    Menus = {'Power Spectral Density','Play on Speaker','Data Information'};
else    
    Menus = {'Data Information'};
end

[ErrorMsg,Subsets,~] = Select_from_List_ME(Menus,1,'Select Presentation Type for Unmodulated Data',true);
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
        
        ErrorMsg = Plot_PSD_ME(message_ME.Content,message_ME.Fs);
        if ~isempty(ErrorMsg)
            return;
        end
        
    case 'Play on Speaker'
        
        if message_ME.Fs<80 || message_ME.Fs>1e6
            ErrorMsg = 'Sample rate, in hertz, of audio data should be between 80 and 1000000.';
            return;
        end
        sound(message_ME.Content',message_ME.Fs);
        
    case 'Data Information'
        
        Display_Sturcture_Info_ME(message_ME,'Unmodulated Information');
        
end