function GUI_CrossValidationResults_Update_ME(Filename,CV_Parameters,CV_Results)

                                        
% This function updates the Modulations-Expert GUI according to Generated/Loaded Cross-Validation Results. 
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
%   Filename: File name corresponding to loaded test results.
%   CV_Parameters: A structure that specifies the parameters of
%       test. Some of the fields are as follows. Depending on CV_Parameters.DM_Type
%       there may be more fields.
%           CV_Parameters.DM_Type: Type of decision machine. Type should be be of the following:
%               'Decision Tree', 'SVM', 'Random Forest, ...'.
%           CV_Parameters.Dataset_FileName The filename of the employed
%               dataset. 
%           CV_Parameters.Dataset_ClassLabels: 1xM cell that contains string labels corresponding to classes in dataset.
%           CV_Parameters.K: The value of K for K-Fold cross-validation
%           CV_Parameters.Weighting_Method: Weighting Method (balanced or
%               uniform)
%   CV_Results: A structure that specifies the results of testing. Depending on CV_Parameters.DM_Type
%       the number of fields for this structre can vary.
%           CV_Results.Pc: Average weighted accuracy 
%           CV_Results.ConfusionMatrix: MxM confusion matrix
%           CV_Results.TrueLabels: True integer-valued labels for all
%               samples (in range 1,2,...,M) 
%           CV_Results.PredictedLabels: Predicted integer-valued labels
%           for all samples (in range 1,2,...,M).
%
% Revisions:
% 2020-Sep-24   function was created

%% Initialization
global CrossValidationResults_ME_Name_TextBox View_CrossValidationResults_PushButton_ME
global CV_Parameters_ME CV_Results_ME

%% Update GUI
set(CrossValidationResults_ME_Name_TextBox,'String',Filename);
set(View_CrossValidationResults_PushButton_ME,'Enable','on');

%% Update Dataset
CV_Parameters_ME = CV_Parameters;
CV_Results_ME = CV_Results;