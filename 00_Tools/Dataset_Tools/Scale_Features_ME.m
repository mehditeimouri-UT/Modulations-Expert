function [Scaled_Dataset,Scaling_Parameters] = Scale_Features_ME(Dataset,Scaling_Option)

% This function takes Dataset and scales the features.
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
%   Dataset: Dataset with L rows (L samples corresponding to L bursts)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   Scaling_Option: Can be one of the following variables:
%       Scaling_Method: String value that shows the method of scaling, the
%           value can be 'z-score', 'min-max', or '' (for no scaling).
%       Scaling_Parameters: A structure that determines the parameters of scaling
%           (x-a)/b for F=C-2 features. The fields are as follows:
%               Scaling_Parameters.A: 1xF vector that shows a values for features.
%               Scaling_Parameters.B: 1xF vector that shows a values for features.
%               Scaling_Parameters.Inf_Value: 1xF vector that shows maximum values
%                   (corresponding to inf) for features
%
% Outputs:
%   Scaled_Dataset: Dataset with L rows (L samples corresponding to L bursts)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   Scaling_Parameters: A structure that determines the parameters of scaling
%       (x-a)/b for F=C-2 features. The fields are as follows:
%           Scaling_Parameters.A: 1xF vector that shows a values for features.
%           Scaling_Parameters.B: 1xF vector that shows a values for features.
%           Scaling_Parameters.Inf_Value: 1xF vector that shows maximum values
%               (corresponding to inf) for features
%
%   Note: In Dataset and Scaled_Dataset, First, the samples of class 1 appear.
%   Second, the the samples of class 2 appear, and so on. Also, for the samples
%   of each class, the bursts with similar file identifier appear consecutively.
%
% Revisions:
% 2020-Sep-24   function was created

%% Initialization
if isstruct(Scaling_Option)
    Scaling_Parameters = Scaling_Option;
else
    Scaling_Method = Scaling_Option;
    Scaling_Parameters = [];
end

%% Determine and set maximum values (corresponding to inf) for features
F = size(Dataset,2)-2; % Number of features

if isempty(Scaling_Parameters)
    Inf_Value = ones(1,F); % vector of inf values for different features
    for j=1:F
        
        % Determine inf val
        inf_val = 10*max(abs(Dataset(isfinite(Dataset(:,j)),j)));
        if ~isempty(inf_val)
            Inf_Value(j) = inf_val;
        end
        
    end
else
    Inf_Value = Scaling_Parameters.Inf_Value;
end

% Set maximum values
for j=1:F
    idx = abs(Dataset(:,j))>Inf_Value(j);
    Dataset(idx,j) = sign(Dataset(idx,j)).*Inf_Value(j);
end

%% Determine the value of a and b in (x-a)/b scaling
if isempty(Scaling_Parameters)
    
    A = zeros(1,F); % vector of a values for different features
    B = zeros(1,F); % vector of b values for different features
    
    switch Scaling_Method
        case 'z-score'
            
            for j=1:F
                A(j) = mean(Dataset(:,j));
                B(j) = std(Dataset(:,j));
                if B(j)==0, B(j) = 1; end
            end
            
        case 'min-max'
            for j=1:F
                A(j) = min(Dataset(:,j));
                B(j) = max(Dataset(:,j))-A(j);
                if B(j)==0, B(j) = 1; end
            end
            
        otherwise
            Inf_Value = inf(1,F);
            A = zeros(1,F);
            B = ones(1,F);
            
    end
    
else
    
    A = Scaling_Parameters.A;
    B = Scaling_Parameters.B;
    
end

%% Scale all features
Scaled_Dataset = Dataset;
Scaled_Dataset(:,1:F) = (Dataset(:,1:F)-repmat(A,size(Dataset,1),1))./repmat(B,size(Dataset,1),1);

%% Set scaling parameters
if isempty(Scaling_Parameters)
    Scaling_Parameters.A = A;
    Scaling_Parameters.B = B;
    Scaling_Parameters.Inf_Value = Inf_Value;
end