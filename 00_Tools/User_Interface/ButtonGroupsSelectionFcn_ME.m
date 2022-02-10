function ButtonGroupsSelectionFcn_ME(~,callbackdata)

% This function defines callback for ButtonGroups of the Modulations-Expert GUI. 
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
% MERCHANTABILITY or FITNESS FOR A PARTICULAxR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <http://www.gnu.org/licenses/>.
%
% Revisions:
% 2020-Sep-26   function was created

global Modem_Buttons_ME AMR_Buttons_ME MachineLearning_Buttons_ME

switch callbackdata.NewValue.String
    case 'Modem'
        
        for j=1:length(AMR_Buttons_ME)
            AMR_Buttons_ME{j}.Visible = 'off';
        end
        
        for j=1:length(MachineLearning_Buttons_ME)
            MachineLearning_Buttons_ME{j}.Visible = 'off';
        end
        
        for j=1:length(Modem_Buttons_ME)
            Modem_Buttons_ME{j}.Visible = 'on';
        end
        
    case 'Machine Learning'
        
        for j=1:length(Modem_Buttons_ME)
            Modem_Buttons_ME{j}.Visible = 'off';
        end
        
        for j=1:length(AMR_Buttons_ME)
            AMR_Buttons_ME{j}.Visible = 'off';
        end
                
        for j=1:length(MachineLearning_Buttons_ME)
            MachineLearning_Buttons_ME{j}.Visible = 'on';
        end
        
    case 'AMR'
        
        for j=1:length(Modem_Buttons_ME)
            Modem_Buttons_ME{j}.Visible = 'off';
        end
        
        for j=1:length(MachineLearning_Buttons_ME)
            MachineLearning_Buttons_ME{j}.Visible = 'off';
        end
        
        for j=1:length(AMR_Buttons_ME)
            AMR_Buttons_ME{j}.Visible = 'on';
        end
end
