function [ErrorMsg,varargout] = Partition_Dataset_ME(Dataset,ClassLabels,Partitions,GenerateError)

% This function partitions a dataset into some sub-datasets.
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
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%
%   Note: Dataset rows are sorted as follows: First, the samples of
%   class 1 appear. Second, the the samples of class 2 appear, and
%   so on. Also for the samples of each class, the bursts with similar file
%   identifier appear consecutively.
%
%   Partitions: A cell array with length N; Each element is a 1x2 vector defines the start and the end of the partiton.
%       Start and end are normalized numbers between 0~1. The partitions may overlap.
%   GenerateError: A logical array with length N; If jth element is true,
%       an error message is generated when partition does not include a specific class (default = true(1,N)) 
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%   varargout: varargout{j} is the row indices in Dataset for the jth sub-dataset
%
% Note: If length(partitions)==1 and partitions{1} is a vector with legnth Np>2,
% then the jth start and end (j=1,2,...,N=Np-1) are defined as partitions{1}(j) and partitions{1}(j+1), respectively.
% In this case, the number of outputs is equal to two. The second output is a cell array. The jth element if this cell
% array shows the jth partition.
%
% Revisions:
% 2020-Sep-24   function was created

%% Initialization
ErrorMsg = '';

M = length(ClassLabels); % Number of classes in Dataset

N = length(Partitions); % Number of partitions
if nargout~=(N+1)
    error('Unpredicted Error: Number of outputs do not match with length of Partitions');
end

if N==1 && length(Partitions{1})>2 % Integrated Partitioning
    
    Integrated_Partitioning = true;
    
    temp = Partitions{1};
    Partitions = cell(1,length(Partitions{1})-1);
    for j=1:length(temp)-1
        Partitions{j} = [temp(j) temp(j+1)];
    end
    N = length(Partitions);
    
else
    Integrated_Partitioning = false;
end

if nargin<4
    GenerateError = true(1,N);
end

%% Find indices of different classes in Dataset
Indices = cell(1,M); % Indices of samples of each class in Dataset
P = cell(1,M); % Index for start of different File IDs in each class
p = cell(1,M); % Normalized index for start of different File IDs in each class
for i=1:length(ClassLabels)
    
    Indices{i} = find(Dataset(:,end-1)==i);
    FrgIndices = Dataset(Indices{i},end);
    P{i} = [0 find(diff(FrgIndices)~=0)' length(FrgIndices)];
    p{i} = P{i}/length(FrgIndices);
    
end

%% Generate start and end indices in Dataset for all sub-datasets
% start and end of class i=1:M for partiton j=1:N
idx_s = zeros(N,M);
idx_e = zeros(N,M);

for j=1:N % Loop over all sub-datasets
    
    Partition = Partitions{j};
    s = Partition(1);
    e = Partition(2);
    
    for i=1:M % Loop over different classes
        
        % start of class i for partiton j
        [~,idx] = min(abs(p{i}-s));
        idx_s(j,i) = P{i}(idx)+1;
        
        % end of class i for partiton j
        [~,idx] = min(abs(p{i}-e));
        idx_e(j,i) = P{i}(idx);
        
    end
end

%% Integrate indices and generate indices for sub-datasets
if Integrated_Partitioning
    varargout = cell(1,1);
else
    varargout = cell(1,N);
end

for j=1:N % Loop over all sub-datasets
    
    Lj = sum(idx_e(j,:)-idx_s(j,:)+1); % Number of samples in the jth sub-dataset
    subdatasetj = zeros(Lj,1);
    cnt = 0;
    for i=1:M % Loop over different classes
        
        lji = idx_e(j,i)-idx_s(j,i)+1;
        if lji==0 && GenerateError(j)
            ErrorMsg = sprintf('Error in partitioning Dataset: Partition %d does not include any samples from class %d',j,i);
            return;
        end
        
        subdatasetj(cnt+(1:lji)) = Indices{i}(idx_s(j,i):idx_e(j,i));
        cnt = cnt+lji;
        
    end
    
    if Integrated_Partitioning
        varargout{1}{j} = subdatasetj;
    else
        varargout{j} = subdatasetj;
    end
end