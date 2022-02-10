function [ErrorMsg,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom] = Expand_Dataset_ME(...
    Dataset_New,FeatureLabels_New,ClassLabels_New,Function_Handles_New,Function_Labels_New,Function_Select_New,Feature_Transfrom_New,...
    Dataset_Old,FeatureLabels_Old,ClassLabels_Old,Function_Handles_Old,Function_Labels_Old,Function_Select_Old,Feature_Transfrom_Old)

% This function adds the features of Dataset_New to Dataset_Old (i.e. it expands Dataset_Old)
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
% Inputs:
%   Dataset_New: Dataset with L rows (L samples corresponding to L bursts)
%       and Cn columns. The first Cn-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   FeatureLabels_New: 1xFn cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels_New: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Function_Handles_New: cell array of function handles used for generating
%       dataset. 
%   Function_Labels_New: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select_New: Cell array of selected features after feature calculation. 
%   Feature_Transfrom_New: A structure which determines the feature tranform if it is non-empty. 
%   Dataset_Old: Dataset with L rows (L samples corresponding to L bursts)
%       and Co columns. The first Co-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   FeatureLabels_Old: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels_Old: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Function_Handles_Old: cell array of function handles used for generating
%       dataset. 
%   Function_Labels_Old: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select_Old: Cell array of selected features after feature calculation. 
%   Feature_Transfrom_Old: A structure which determines the feature tranform if it is non-empty. 
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%   Dataset: Dataset with L rows (L samples corresponding to L bursts)
%       and C columns. The first C columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the bursts, respectively.
%   FeatureLabels: 1xF cell (F <= Fo+Fn). Cell contents are strings denoting
%       the name of features corresponding to the columns of Dataset.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Function_Handles: cell array of function handles used for generating
%       dataset. 
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%   Feature_Transfrom: A structure which determines the feature tranform if it is non-empty. 
%
%   Note 1: In Dataset_New, Dataset_Old, and Dataset, First, the samples of class 1 appear.
%   Second, the the samples of class 2 appear, and so on. Also, for the samples 
%   of each class, the bursts with similar file identifier appear consecutively.
%
%   Note 2: Repetitive feature are omitted.
%
% Revisions:
% 2020-Sep-23   function was created
% 2021-Jan-03   Feature_Transfrom inputs and Feature_Transfrom output were added

%% Initialization
ErrorMsg = '';
Dataset = [];
FeatureLabels = [];
ClassLabels = [];
Function_Handles = [];
Function_Labels = [];
Function_Select = [];
Feature_Transfrom = [];

%% Check Datasets
if ~isequal(Dataset_Old(:,end-1:end),Dataset_New(:,end-1:end)) || ~isequal(ClassLabels_Old,ClassLabels_New)
    ErrorMsg = 'Datasets sizes, output labels, or fileIDs do not match. Expanding is aborted.';
    return;
else
    Dataset = [Dataset_Old(:,1:end-2) Dataset_New(:,1:end)];
    ClassLabels = ClassLabels_Old;
    
    Function_Handles = [Function_Handles_Old Function_Handles_New];
    Function_Labels = [Function_Labels_Old Function_Labels_New];
    Function_Select = [Function_Select_Old Function_Select_New];
    if ~isempty(Feature_Transfrom_New) || ~isempty(Feature_Transfrom_Old)
        
        if isempty(Feature_Transfrom_Old)
            Coef_Old = eye(size(Dataset_Old,2)-2);
        else
            Coef_Old = Feature_Transfrom_Old.Coef;
        end
        
        if isempty(Feature_Transfrom_New)
            Coef_New = eye(size(Dataset_New,2)-2);
        else
            Coef_New = Feature_Transfrom_New.Coef;
        end
        
        for j=1:length(FeatureLabels_Old)
            FeatureLabels_Old{j} = sprintf('%s_Old',FeatureLabels_Old{j});
        end
        
        for j=1:length(FeatureLabels_New)
            FeatureLabels_New{j} = sprintf('%s_New',FeatureLabels_New{j});
        end
        
        Feature_Transfrom.Coef = [[Coef_Old ; zeros(size(Coef_New,1),size(Coef_Old,2))] [zeros(size(Coef_Old,1),size(Coef_New,2)) ; Coef_New]];
        
    end
    FeatureLabels = [FeatureLabels_Old FeatureLabels_New];    
    
    % Repetitive feature are omitted
    if isempty(Feature_Transfrom_New) && isempty(Feature_Transfrom_Old)
        UniqueFeatLabels = unique(FeatureLabels);
        IncludedFeatLabels = false(size(UniqueFeatLabels));
        cnt = 0;
        DelFeatIdx = false(1,length(FeatureLabels));
        for i=1:length(Function_Select)
            for j=1:length(Function_Select{i})
                if Function_Select{i}(j)
                    cnt = cnt+1;
                    idx = find(strcmp(UniqueFeatLabels,Function_Labels{i}{j}));
                    if ~IncludedFeatLabels(idx)
                        IncludedFeatLabels(idx) = true;
                    else
                        DelFeatIdx(cnt) = true;
                        Function_Select{i}(j) = false;
                    end
                end
            end
        end
        FeatureLabels(DelFeatIdx) = [];
        Dataset(:,[DelFeatIdx false false]) = [];
    end
end