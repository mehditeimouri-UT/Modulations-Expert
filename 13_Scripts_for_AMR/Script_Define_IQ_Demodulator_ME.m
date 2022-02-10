function ErrorMsg = Script_Define_IQ_Demodulator_ME

% This function gets the parameter of demodulation from user and defines I/Q demodulator.
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
global iq_demodulator_ME
global View_IQ_Demodulator_PushButton_ME Apply_IQ_Demodulator_PushButton_ME Demodulated_IQ_PushButton_ME

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Define I/Q Demodulator
ModulationSelection = {'Analog','Digital'};
[ErrorMsg,Subsets,~] = Select_from_List_ME(ModulationSelection,1,'Select Modulation Type',true);

if ~isempty(ErrorMsg)
    return;
end

[Mod,ErrorMsg] = Get_Modulation_Parameters_and_Define_Modulator_ME(ModulationSelection{Subsets{1}});
if ~isempty(ErrorMsg)
    return;
end

iq_demodulator_ME = Mod;


%% Enable Next Box in AMR Block
View_IQ_Demodulator_PushButton_ME.Enable = 'on';
Apply_IQ_Demodulator_PushButton_ME.Enable = 'on';

Demodulated_IQ_PushButton_ME.BackgroundColor = [1 1 1];
Demodulated_IQ_PushButton_ME.Enable = 'off';