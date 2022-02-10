function ErrorMsg = Script_Present_Modulated_Information_ME

% This function presents modulated information in ones of the
% following ways:
%   (I) Power Spectral Density
%   (II) Signal Information
%   (III) Save to WAV File
%   (IV) Pass Signal to AMR
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
global modulator_output_ME iq_information_ME
global modulator_ME
global IQ_information_PushButton_ME
global Define_IQ_Demodulator_PushButton_ME View_IQ_Demodulator_PushButton_ME Apply_IQ_Demodulator_PushButton_ME Demodulated_IQ_PushButton_ME
global IQ_Demodulator_Parameters_Estimation_PushButton_ME IQ_Blind_Demodulator_PushButton_ME
global AMR_Radio_Button_ME 
global MinimumBurstLength
global IQ_EstimationResults_Text_ME

%% Determine Presentation Type
[ErrorMsg,Subsets,~] = Select_from_List_ME({'Power Spectral Density','Signal Information','Save to WAV File','Pass Signal to AMR'}...
    ,1,'Select Presentation Type for Modulated Data',true);
if ~isempty(ErrorMsg)
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Perform Operation
switch Subsets{1}
    
    case 1 % Power Spectral Density
        
        ErrorMsg = Plot_PSD_ME(modulator_output_ME.Content,modulator_output_ME.fs);
        if ~isempty(ErrorMsg)
            return;
        end
        
    case 2 % Signal Information
        
        Display_Sturcture_Info_ME(modulator_output_ME,'Modulated Signal');
        
    case 3 % Save to WAV File
        
        [FileName,PathName] = uiputfile({'*.wav' , 'WAV File'},'Save I/Q Data as',modulator_ME.Type);
        if isequal(FileName,0)
            ErrorMsg = 'Process is aborted. No file was selected by user for saving I/Q data.';
            return;
        end
        
        GUI_MainEditBox_Update_ME(true);
        GUI_MainEditBox_Update_ME(false,'Please wait ...');
        pause(0.01);
        x = modulator_output_ME.Content;
        x = x/max(abs(x));
        audiowrite([PathName FileName],[real(x) ; imag(x)]',modulator_output_ME.fs);
        GUI_MainEditBox_Update_ME(false,'WAV File is successfully written.');
        
    case 4 % Pass Signal to AMR
        
        if length(modulator_output_ME.Content)<MinimumBurstLength
            ErrorMsg = sprintf('The length of the input data passed to AMR unit should be at least equal to %d',MinimumBurstLength);
            return;
        end
        
        % Pass Signal
        iq_information_ME = [];
        iq_information_ME.Content = modulator_output_ME.Content;
        iq_information_ME.fs = modulator_output_ME.fs;
        
        % Enable Next Box in AMR Block
        IQ_information_PushButton_ME.Enable = 'on';
        IQ_information_PushButton_ME.BackgroundColor = [0 1 0];
        
        Define_IQ_Demodulator_PushButton_ME.Enable = 'on';
        View_IQ_Demodulator_PushButton_ME.Enable = 'off'; 
        Apply_IQ_Demodulator_PushButton_ME.Enable = 'off'; 
        
        IQ_Demodulator_Parameters_Estimation_PushButton_ME.Enable = 'on';
        IQ_Blind_Demodulator_PushButton_ME.Enable = 'off';
        
        Demodulated_IQ_PushButton_ME.BackgroundColor = [1 1 1];
        Demodulated_IQ_PushButton_ME.Enable = 'off'; 
        
        IQ_EstimationResults_Text_ME.String = '';
        
        % Change The Status of Radio Button Group
        AMR_Radio_Button_ME.Value = 1;
        callbackdata.NewValue.String = 'AMR';
        ButtonGroupsSelectionFcn_ME(0,callbackdata);

end
