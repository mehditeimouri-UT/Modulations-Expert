function SelectedLabels = Select_CellContents_ME(Labels,Subsets)

% This function gets a cell array and returns the array of sub-cells according to an indexing input.
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
%   Labels: A 1xN cell array.
%   Subsets: The 1xM cell array of indexing input.
%
% Output:
%   SelectedLabels: The 1xM array of sub-cells according to the indexing
%       input.
%
% Revisions:
% 2020-Sep-23   function was created

%% Initialization
M = length(Subsets);
SelectedLabels = cell(1,M);
for j=1:M
    SelectedLabels{j} = Labels(Subsets{j});
end