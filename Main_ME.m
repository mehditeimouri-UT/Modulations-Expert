function Main_ME

% This function is the main function of Modulations-Expert software.
%
% Copyright (C) 2021 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
%   2020-Aug-26   function was created
%   2021-Jan-03   Feature_Transfrom_ME and DM_Feature_Transfrom_ME were defined and included

%% Initialization
global Main_ME_fig

if ~isempty(Main_ME_fig)
    figure(Main_ME_fig);
    return;
end

global AllPaths_ME

ver = '2.0';
currentFolder = which('Main_ME.m');
currentFolder(strfind(currentFolder,'Main_ME.m')-1:end) = [];
AllPaths_ME = genpath(currentFolder);
addpath(AllPaths_ME);

Main_ME_fig = figure;
set(Main_ME_fig,'Name',sprintf('Modulations-Expert v%s',ver),'NumberTitle','off',...
    'Toolbar','None','MenuBar','None','DeleteFcn',@Close_Main_ME);

%% Global Constants
global MaxDataChannels_ME MinInformationLength MaxInformationLength TypicalInformationLength
global AnalogModTypes DigitalModTypes LinearDigitalModTypes
global MinimumBurstLength MaximumBurstLength MinimumBursts_per_Modulation MaximumBursts_per_Modulation MaximumFragments_per_AudioFile
global MaximumBursts_per_AudioFile

MaxDataChannels_ME = 2; % Maximum Data channel is set to 2, i.e. stereo data
MinInformationLength = 100; % Minimum Data length (per channel) of Modulator
MaxInformationLength = 1e7; % Maximum Data length (per channel) of Modulator
TypicalInformationLength = 1e4; % Typical Data length (per channel) of Modulator
MinimumBurstLength = 512; % Minimum Burst Length
MaximumBurstLength = 65536; % Maximum Burst Length
MinimumBursts_per_Modulation = 1000; % Minimum Number of total bursts in a specific modulation Dataset
MaximumBursts_per_Modulation = 1000000; % Maximim Number of total bursts in a specific modulation Dataset
MaximumFragments_per_AudioFile = 100; % Maximum Number of Fragments per each audio file
MaximumBursts_per_AudioFile = 1000; % Maximum Number of Bursts per each audio file

AnalogModTypes = {'am', 'dsb', 'usb', 'lsb', 'isb', 'fm', 'pm'}; % Analog Modulation Types
DigitalModTypes = {'msk', 'gmsk', 'fsk', 'psk', 'dpsk', 'oqpsk', 'qam', 'ask'}; % Digital Modulation Types
LinearDigitalModTypes = {'psk', 'dpsk', 'oqpsk', 'qam', 'ask'}; % Linear Digital Modulation Types

%% Define Text Box for Information
global TextBox_ME TextBox_ME_String

TextBox_ME = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1000,...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.3 0 0.7 1],...
    'HorizontalAlignment','Left');
TextBox_ME_String = {};

%% Radio Buttons for Different Modes

% Radio Buttons
global ButtonGroups_ME Modem_Radio_Button_ME AMR_Radio_Button_ME MachineLearning_Radio_Button_ME

ButtonGroups_ME = uibuttongroup('Visible','on','Units','normalized',...
    'Position',[0 0.84 0.3 0.16],'SelectionChangedFcn',@ButtonGroupsSelectionFcn_ME);
              
Modem_Radio_Button_ME = uicontrol(ButtonGroups_ME,'Style','radiobutton','Units','normalized',...
    'String','Modem','Position',[0 0.7 1 0.3],'HandleVisibility','off');              

MachineLearning_Radio_Button_ME = uicontrol(ButtonGroups_ME,'Style','radiobutton','Units','normalized',...
    'String','Machine Learning','Position',[0 0.4 1 0.3],'HandleVisibility','off');              

AMR_Radio_Button_ME = uicontrol(ButtonGroups_ME,'Style','radiobutton','Units','normalized',...
    'String','AMR','Position',[0 0.1 1 0.3],'HandleVisibility','off');              

%% Define Modem Section (Data Generation, Modulation, Channel, and Demodulation)

% Modem Buttons
global Modem_Buttons_ME
global Generate_Information_PushButton_ME Load_Information_PushButton_ME Unmodulated_information_PushButton_ME
global Define_Modulator_PushButton_ME View_Modulator_PushButton_ME Apply_Modulation_PushButton_ME Modulated_Data_PushButton_ME
global Define_Channel_PushButton_ME View_Channel_PushButton_ME Apply_Channel_PushButton_ME Channel_Output_PushButton_ME
global Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME

% Data Generation
Load_Information_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Load Information',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.78 0.2 0.05],...
    'Enable','on','Callback',@RunMethodsforMainGUIPushButtons_ME);
Generate_Information_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Generate Information',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.73 0.2 0.05],...
    'Enable','on','Callback',@RunMethodsforMainGUIPushButtons_ME);
Unmodulated_information_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', '',...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.125 0.66 0.05 0.07],...
    'Enable','off','Callback',@RunMethodsforUnmodulatedData_ME);

% Define and Apply Modulation
Define_Modulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Define Modulator',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.61 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
View_Modulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Modulator',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.56 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Apply_Modulation_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Apply Modulation',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.51 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Modulated_Data_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', '',...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.125 0.44 0.05 0.07],...
    'Enable','off','Callback',@RunMethodsforModulatedData_ME);

% Define and Apply Channel
Define_Channel_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Define Channel',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.39 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
View_Channel_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Channel',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.34 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Apply_Channel_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Apply Channel',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.29 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Channel_Output_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', '',...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.125 0.22 0.05 0.07],...
    'Enable','off','Callback',@RunMethodsforChannelOutput_ME);

% Define and Apply Demodulation
Define_Demodulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Define Demodulator',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.17 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
View_Demodulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Demodulator',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.12 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Apply_Demodulation_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Apply Demodulation',...
    'BackgroundColor',[1 1 0],'Units','normalized','Position', [0.05 0.07 0.2 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Demodulated_Data_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', '',...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.125 0 0.05 0.07],...
    'Enable','off','Callback',@RunMethodsforDeModulatedData_ME);

Modem_Buttons_ME = {Generate_Information_PushButton_ME,Load_Information_PushButton_ME Unmodulated_information_PushButton_ME,...
    Define_Modulator_PushButton_ME View_Modulator_PushButton_ME Apply_Modulation_PushButton_ME Modulated_Data_PushButton_ME,...
    Define_Channel_PushButton_ME View_Channel_PushButton_ME Apply_Channel_PushButton_ME Channel_Output_PushButton_ME,...
    Define_Demodulator_PushButton_ME View_Demodulator_PushButton_ME Apply_Demodulation_PushButton_ME Demodulated_Data_PushButton_ME};

%% Define AMR Section

% AMR Buttons
global AMR_Buttons_ME
global Load_IQ_Information_PushButton_ME IQ_information_PushButton_ME
global Define_IQ_Demodulator_PushButton_ME View_IQ_Demodulator_PushButton_ME Apply_IQ_Demodulator_PushButton_ME Demodulated_IQ_PushButton_ME
global IQ_Demodulator_Parameters_Estimation_PushButton_ME IQ_Blind_Demodulator_PushButton_ME IQ_EstimationResults_Text_ME

% I/Q Data Generation
Load_IQ_Information_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Load I/Q Information',...
    'BackgroundColor',[0 1 1],'Units','normalized','Position', [0.02 0.78 0.26 0.05],...
    'Enable','on','Callback',@RunMethodsforMainGUIPushButtons_ME);
IQ_information_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', '',...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.125 0.71 0.05 0.07],...
    'Enable','off','Callback',@RunMethodsforIQInformation_ME);

% Define and Apply Demodulation
Define_IQ_Demodulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Define I/Q Demodulator',...
    'BackgroundColor',[0 1 1],'Units','normalized','Position', [0.02 0.66 0.26 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
View_IQ_Demodulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View I/Q Demodulator',...
    'BackgroundColor',[0 1 1],'Units','normalized','Position', [0.02 0.61 0.26 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Apply_IQ_Demodulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Apply I/Q Demodulator',...
    'BackgroundColor',[0 1 1],'Units','normalized','Position', [0.02 0.56 0.26 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
IQ_Demodulator_Parameters_Estimation_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Parameters Estimation',...
    'BackgroundColor',[0.2 0.9 0.7],'Units','normalized','Position', [0.02 0.50 0.26 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
IQ_Blind_Demodulator_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'Blind Demodulation',...
    'BackgroundColor',[0.2 0.9 0.7],'Units','normalized','Position', [0.02 0.45 0.26 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);
Demodulated_IQ_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', '',...
    'BackgroundColor',[1 1 1],'Units','normalized','Position', [0.125 0.38 0.05 0.07],...
    'Enable','off','Callback',@RunMethodsforDemodulatedIQ_ME);
IQ_EstimationResults_Text_ME = uicontrol(Main_ME_fig,'Style', 'text', 'String','',...
    'Units','normalized','Position', [0.02 0.05 0.26 0.3],...
    'HorizontalAlignment','left');

AMR_Buttons_ME = {Load_IQ_Information_PushButton_ME IQ_information_PushButton_ME ...
    Define_IQ_Demodulator_PushButton_ME View_IQ_Demodulator_PushButton_ME Apply_IQ_Demodulator_PushButton_ME ...
    Demodulated_IQ_PushButton_ME IQ_Demodulator_Parameters_Estimation_PushButton_ME IQ_Blind_Demodulator_PushButton_ME,IQ_EstimationResults_Text_ME};
for j=1:length(AMR_Buttons_ME)
    AMR_Buttons_ME{j}.Visible = 'off';
end

%% Define Machine Learning Section

% Machine Learning Buttons
global MachineLearning_Buttons_ME
global Dataset_ME_Title_TextBox Dataset_ME_Name_TextBox 
global Dataset_ME_Classes_TextBox View_Classes_PushButton_ME
global Dataset_ME_Features_TextBox View_Features_PushButton_ME
global DecisionMachine_ME_Title_TextBox DecisionMachine_ME_Name_TextBox
global DecisionMachine_ME_Validation_TextBox View_Decision_Machine_PushButton_ME
global TestResults_ME_Title_Textbox TestResults_ME_Name_TextBox View_TestResults_PushButton_ME
global CrossValidationResults_ME_Title_Textbox CrossValidationResults_ME_Name_TextBox View_CrossValidationResults_PushButton_ME

% Dataset Name
Dataset_ME_Title_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0.01 0.79 0.28 0.04],...
    'HorizontalAlignment','Center','String','Generated/Loaded Dataset');

Dataset_ME_Name_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.75 0.28 0.04],...
    'HorizontalAlignment','Center');

% Class Labels
Dataset_ME_Classes_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.71 0.14 0.04],...
    'HorizontalAlignment','Center');

View_Classes_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Classes',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.15 0.71 0.14 0.04],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);

% Feature Labels
Dataset_ME_Features_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.67 0.14 0.04],...
    'HorizontalAlignment','Center');

View_Features_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Features',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.15 0.67 0.14 0.04],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);

% Decision Machine 
DecisionMachine_ME_Title_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0.01 0.63 0.28 0.04],...
    'HorizontalAlignment','Center','String','Decision Machine');

DecisionMachine_ME_Name_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.59 0.28 0.04],...
    'HorizontalAlignment','Center');

DecisionMachine_ME_Validation_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.55 0.28 0.04],...
    'HorizontalAlignment','Center');

View_Decision_Machine_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Decision Machine',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.01 0.51 0.28 0.04],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);

% Decision Machine Test
TestResults_ME_Title_Textbox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0.01 0.47 0.28 0.04],...
    'HorizontalAlignment','Center','String','Test Results of Machine');

TestResults_ME_Name_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.43 0.28 0.04],...
    'HorizontalAlignment','Center');

View_TestResults_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Test Results',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.01 0.39 0.28 0.04],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);

% Cross-Validation Results
CrossValidationResults_ME_Title_Textbox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0.01 0.35 0.28 0.04],...
    'HorizontalAlignment','Center','String','Cross-Validation Results');

CrossValidationResults_ME_Name_TextBox = uicontrol(Main_ME_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.01 0.31 0.28 0.04],...
    'HorizontalAlignment','Center');

View_CrossValidationResults_PushButton_ME = uicontrol(Main_ME_fig,'Style', 'pushbutton', 'String', 'View Cross-Validation Results',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.01 0.27 0.28 0.04],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_ME);

MachineLearning_Buttons_ME = {Dataset_ME_Title_TextBox,Dataset_ME_Name_TextBox,Dataset_ME_Classes_TextBox,View_Classes_PushButton_ME,...
    Dataset_ME_Features_TextBox,View_Features_PushButton_ME,DecisionMachine_ME_Title_TextBox,DecisionMachine_ME_Name_TextBox,...
    DecisionMachine_ME_Validation_TextBox,View_Decision_Machine_PushButton_ME,TestResults_ME_Title_Textbox,TestResults_ME_Name_TextBox,...
    View_TestResults_PushButton_ME,CrossValidationResults_ME_Title_Textbox,CrossValidationResults_ME_Name_TextBox,View_CrossValidationResults_PushButton_ME};

for j=1:length(MachineLearning_Buttons_ME)
    MachineLearning_Buttons_ME{j}.Visible = 'off';
end

%% Define File Menu and Submenus
File_Menu = uimenu('Label','File');
uimenu(File_Menu,'Label','Load Dataset','Callback',@RunMethodsforMenus_ME);
uimenu(File_Menu,'Label','Load Decision Machine','Callback',@RunMethodsforMenus_ME);
uimenu(File_Menu,'Label','Load Test Results','Callback',@RunMethodsforMenus_ME);
uimenu(File_Menu,'Label','Load Cross-Validation Results','Callback',@RunMethodsforMenus_ME);
uimenu(File_Menu,'Label','Exit','Callback','closereq','Separator','on');

%% Define Dataset Menu and Submenus
Dataset_Menu = uimenu('Label','Dataset');
uimenu(Dataset_Menu,'Label','Generate Dataset of Bursts for Digital Modulations','Separator','on','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Generate Dataset of Bursts for Analog Modulations','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Generate Dataset of Bursts from I/Q WAV File','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Generate Dataset from Bursts','Separator','on','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Generate Dataset (for Decision Machine) from Bursts','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Random Permutation of Dataset','Separator','on','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Expand Dataset','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Merge Labels in Dataset','Callback',@RunMethodsforMenus_ME);
uimenu(Dataset_Menu,'Label','Select Sub-Dataset','Callback',@RunMethodsforMenus_ME);

%% Define Learning Menu and Submenus
Learning_Menu = uimenu('Label','Learning');
uimenu(Learning_Menu,'Label','Train Decision Machine','Callback',@RunMethodsforMenus_ME);
uimenu(Learning_Menu,'Label','Test Decision Machine','Callback',@RunMethodsforMenus_ME);
uimenu(Learning_Menu,'Label','Cross-Validation of Decision Machine','Callback',@RunMethodsforMenus_ME);

%% Define Feature Selection Menu and Submenus
FeatureSelection_Menu = uimenu('Label','Feature Selection');
uimenu(FeatureSelection_Menu,'Label','Embedded: Decision Tree','Callback',@RunMethodsforMenus_ME);
uimenu(FeatureSelection_Menu,'Label','Filter: Pearson Correlation Coefficient','Callback',@RunMethodsforMenus_ME);
uimenu(FeatureSelection_Menu,'Label','Wrapper: Sequential Forward Selection with LDA','Callback',@RunMethodsforMenus_ME);
uimenu(FeatureSelection_Menu,'Label','Feature Transformation: Principal Component Analysis (PCA)','Callback',@RunMethodsforMenus_ME);

%% Define Visualization Menu and Submenus
Visualization_Menu = uimenu('Label','Visualization');
uimenu(Visualization_Menu,'Label','t-Distributed Stochastic Neighbor Embedding (t-SNE)','Callback',@RunMethodsforMenus_ME);
uimenu(Visualization_Menu,'Label','Box Plot of Features','Callback',@RunMethodsforMenus_ME);
uimenu(Visualization_Menu,'Label','Plot Feature Histogram','Callback',@RunMethodsforMenus_ME);
uimenu(Visualization_Menu,'Label','Display Samples in Feature Space','Callback',@RunMethodsforMenus_ME);

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% ------------------------------------- GUI Subfunctions -------------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Define Callback Functions for Menus and Submenus
function RunMethodsforMenus_ME(source,~)

global MachineLearning_Radio_Button_ME

% Clear the multi-line edit ui in Modulations-Expert GUI.
GUI_MainEditBox_Update_ME(true);
GUI_MainEditBox_Update_ME(false,'Please wait ...');

% Run callback function
switch get(source,'Label')
    
    case 'Generate Dataset of Bursts for Digital Modulations'
        ErrorMsg = Script_Generate_Dataset_of_Bursts_for_Digital_Modulations_ME;

    case 'Generate Dataset of Bursts for Analog Modulations'
        ErrorMsg = Script_Generate_Dataset_of_Bursts_for_Analog_Modulations_ME;
        
    case 'Generate Dataset of Bursts from I/Q WAV File'
        ErrorMsg = Script_Generate_Dataset_of_Bursts_from_IQ_WAV_ME;        

    case 'Generate Dataset from Bursts'
        ErrorMsg = Script_GenerateDataset_from_BurstsDataset_ME;
        
    case 'Load Dataset'
        ErrorMsg = Script_Load_Dataset_ME;       

    case 'Random Permutation of Dataset'
        ErrorMsg = Script_RandomPermute_Dataset_ME;
        
    case 'Expand Dataset'
        ErrorMsg = Script_Expand_Dataset_ME;

    case 'Merge Labels in Dataset'
        ErrorMsg = Script_MergeLabels_Dataset_ME;
        
    case 'Select Sub-Dataset'
        ErrorMsg = Script_Select_SubDataset_ME;

    case 'Train Decision Machine'
        ErrorMsg = Script_DecisionMachine_Train_ME;

    case 'Test Decision Machine'
        ErrorMsg = Script_DecisionMacine_Test_ME;
        
    case 'Cross-Validation of Decision Machine'
        ErrorMsg = Script_DecisionMachine_CrossValidation_ME;
        
    case 'Load Decision Machine'
        ErrorMsg = Script_Load_DecisionMachine_ME;

    case 'Load Test Results'
        ErrorMsg = Script_Load_DecisionMachine_Test_Results_ME;
        
    case 'Load Cross-Validation Results'
        ErrorMsg = Script_Load_CrossValidation_Results_ME;
        
    case 'Generate Dataset (for Decision Machine) from Bursts'
        ErrorMsg = Script_GenerateDataset_for_DecisionMachine_ME;

    case 'Embedded: Decision Tree'
        ErrorMsg = Script_FeatureSelection_with_DecisionTree_ME;
    
    case 'Wrapper: Sequential Forward Selection with LDA'
        ErrorMsg = Script_SequentialForward_FeatureSelection_ME;

    case 'Filter: Pearson Correlation Coefficient'
        ErrorMsg = Script_FeatureSelection_with_PearsonCorrelationCoefficient_ME;
        
    case 'Feature Transformation: Principal Component Analysis (PCA)'
        ErrorMsg = Script_FeatureSelection_with_PCA_ME;
        
    case 'Plot Feature Histogram'
        ErrorMsg = Script_Plot_FeatureHistogram_ME;
        
    case 'Display Samples in Feature Space'
        ErrorMsg = Script_Plot_Samples_in_FeatureSpace_ME;
    
    case 't-Distributed Stochastic Neighbor Embedding (t-SNE)'
        ErrorMsg = Script_t_SNE_Visualization_ME;
        
    case 'Box Plot of Features'
        ErrorMsg = Script_Box_Plot_of_Features_ME;

end

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
    return;
end

% Change The Status of Radio Button Group
switch get(source,'Label')
    
    case {'Load Dataset','Load Decision Machine','Load Test Results',...
            'Load Cross-Validation Results','Generate Dataset (for Decision Machine) from Bursts','Generate Dataset from Bursts',...
            'Random Permutation of Dataset','Expand Dataset','Merge Labels in Dataset','Select Sub-Dataset','Train Decision Machine',...
            'Test Decision Machine','Cross-Validation of Decision Machine'}
        
        MachineLearning_Radio_Button_ME.Value = 1;
        callbackdata.NewValue.String = 'Machine Learning';
        ButtonGroupsSelectionFcn_ME(0,callbackdata);        
        
    otherwise
end

%% Define Callback Functions for Main GUI PushButtons
function RunMethodsforMainGUIPushButtons_ME(source,~)

global ClassLabelsandNumbers_ME FeatureLabels_ME
global DM_TrainingParameters_ME DM_TrainingResults_ME DecisionMachine_ME DecisionMachine_CL_ME DM_ClassLabels_ME
global TestParameters_ME TestResults_ME
global CV_Parameters_ME CV_Results_ME

% Run callback function
ErrorMsg = '';
switch get(source,'String')
    
    case 'Generate Information'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_Generate_Information_ME;
        
    case 'Load Information'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_Load_Information_ME;
        
    case 'Define Modulator'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_Define_Modulator_ME;
        
    case 'View Modulator'
        Script_View_Modulator_ME;
        
    case 'Apply Modulation'
        Script_Apply_Modulation_ME;
    
    case 'Define Channel'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_Define_Channel_ME;
    
    case 'Apply Channel'
        Script_Apply_Channel_ME;
    
    case 'View Channel'
        Script_View_Channel_ME;
        
    case 'Define Demodulator'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_Define_Demodulator_ME;

    case 'View Demodulator'
        Script_View_Demodulator_ME;
        
    case 'Apply Demodulation'
        GUI_MainEditBox_Update_ME(true);
        GUI_MainEditBox_Update_ME(false,'Please wait ...');
        ErrorMsg = Script_Apply_Demodulation_ME;
        
    case 'Load I/Q Information'
        GUI_MainEditBox_Update_ME(true);
        GUI_MainEditBox_Update_ME(false,'Please wait ...');
        ErrorMsg = Script_Load_IQ_Information_ME;
    
    case 'Define I/Q Demodulator'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_Define_IQ_Demodulator_ME;
        
    case 'View I/Q Demodulator'
        Script_View_IQ_Demodulator_ME;

    case 'Apply I/Q Demodulator'
        GUI_MainEditBox_Update_ME(true);
        Script_Apply_IQ_Demodulation_ME;
        
    case 'Parameters Estimation'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_IQ_Parameters_Estimation_ME;
        
    case 'Blind Demodulation'
        GUI_MainEditBox_Update_ME(true);
        ErrorMsg = Script_IQ_Blind_Demodulation_ME;
                
    case 'View Classes'
        Display_StringCell_ME(ClassLabelsandNumbers_ME,'List of classes and number of samples for each class in Dataset');
        
    case 'View Features'
        Display_StringCell_ME(FeatureLabels_ME,'List of Features in Dataset');
        
    case 'View Decision Machine'
        GUI_MainEditBox_Update_ME(true);
        Display_DecisionMachine_ME(DM_TrainingParameters_ME,DM_TrainingResults_ME,DecisionMachine_ME,DecisionMachine_CL_ME,DM_ClassLabels_ME);
        
    case 'View Test Results'
        GUI_MainEditBox_Update_ME(true);
        Display_TestResults_ME(TestParameters_ME,TestResults_ME);
        
    case 'View Cross-Validation Results'
        GUI_MainEditBox_Update_ME(true);
        Display_CrossValidationResults_ME(CV_Parameters_ME,CV_Results_ME);
        
    otherwise
end

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Define Callback Functions for Unmodulated Data
function RunMethodsforUnmodulatedData_ME(~,~)

GUI_MainEditBox_Update_ME(true);

% Presenting Data
ErrorMsg = Script_Present_Unmodulated_Information_ME;

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Define Callback Functions for Modulated Data
function RunMethodsforModulatedData_ME(~,~)

GUI_MainEditBox_Update_ME(true);

% Presenting Data
ErrorMsg = Script_Present_Modulated_Information_ME;

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Define Callback Functions for Channel Output
function RunMethodsforChannelOutput_ME(~,~)

GUI_MainEditBox_Update_ME(true);

% Presenting Data
ErrorMsg = Script_Present_Channel_Output_ME;

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Define Callback Functions for Demodulated Data
function RunMethodsforDeModulatedData_ME(~,~)

GUI_MainEditBox_Update_ME(true);

% Presenting Data
ErrorMsg = Script_Present_Demodulated_Information_ME;

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Define Callback Functions for I/Q Information
function RunMethodsforIQInformation_ME(~,~)

GUI_MainEditBox_Update_ME(true);

% Presenting Data
ErrorMsg = Script_Present_IQ_Information_ME;

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Define Callback Functions for Demodulated I/Q
function RunMethodsforDemodulatedIQ_ME(~,~)

GUI_MainEditBox_Update_ME(true);

% Presenting Data
ErrorMsg = Script_Present_Demodulated_IQ_ME;

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_ME(false,ErrorMsg);
    GUI_MainEditBox_Update_ME(false,'-----------------------------------------------------------','red');
end

%% Close GUI: Callback function
function Close_Main_ME(~,~)

global Main_ME_fig 
global AllPaths_ME
global message_ME modulator_ME modulator_output_ME channel_ME channel_output_ME demodulator_ME demodulated_message_ME
global iq_information_ME demodulated_iq_ME iq_demodulator_ME
global Dataset_ME ClassLabels_ME FeatureLabels_ME Function_Handles_ME Function_Labels_ME Function_Select_ME ClassLabelsandNumbers_ME
global DM_TrainingParameters_ME DM_TrainingResults_ME DecisionMachine_ME DecisionMachine_CL_ME DM_ClassLabels_ME DM_FeatureLabels_ME
global DM_Function_Handles_ME DM_Function_Labels_ME DM_Function_Select_ME
global TestParameters_ME TestResults_ME
global CV_Parameters_ME CV_Results_ME
global Feature_Transfrom_ME DM_Feature_Transfrom_ME

rmpath(AllPaths_ME);

% Remove all global variables
Main_ME_fig = [];
message_ME = [];
modulator_ME = [];
modulator_output_ME = [];
channel_ME = [];
channel_output_ME = [];
demodulator_ME = [];
demodulated_message_ME = [];
iq_information_ME = [];
demodulated_iq_ME = [];
iq_demodulator_ME = [];
Dataset_ME = [];
ClassLabels_ME = [];
FeatureLabels_ME = [];
Function_Handles_ME = [];
Function_Labels_ME = [];
Function_Select_ME = [];
ClassLabelsandNumbers_ME = [];
DM_TrainingParameters_ME = [];
DM_TrainingResults_ME = []; 
DecisionMachine_ME = []; 
DecisionMachine_CL_ME = [];
DM_ClassLabels_ME = [];
DM_FeatureLabels_ME = [];
DM_Function_Handles_ME = [];
DM_Function_Labels_ME = [];
DM_Function_Select_ME = [];
TestParameters_ME = [];
TestResults_ME = [];
CV_Parameters_ME = [];
CV_Results_ME = [];
Feature_Transfrom_ME = [];
DM_Feature_Transfrom_ME = [];