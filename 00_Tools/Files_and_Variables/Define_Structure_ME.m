% This function defines a structure with default fields and values.
% Moreover, arbitrary number of fields can be changed by user.
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
%   default_fields: 1xN cell array of strings denoting the field names
%   default_values: 1xN cell array denoting the field values
%   fields_values_pairs: Row cell array with length 2xL that can be used to assign non-default values to some fields
%       For i=1,2,3,...,L, fields_values_pairs{2*i-1} is the desired field name and
%       fields_values_pairs{2*i} is the desired field value.
%
% Output:
%   S: Defined structure.
%
% Revisions:
% 2020-Sep-01   function was created

function S = Define_Structure_ME(default_fields,default_values,fields_values_pairs)

% Assign default values
N = length(default_fields);
for j=1:N
    S.(default_fields{j}) = default_values{j};
end

% Change Default Values Indicated by fields_values_pairs
L = length(fields_values_pairs)/2;
if L==0
    return;
end
fields_values_pairs = reshape(fields_values_pairs,2,[]);
for i=1:L
    if sum(cellfun(@strcmp,default_fields,repmat(fields_values_pairs(1,i),1,length(default_fields))))~=1
        error('Error in using Define_Structure_ME');
    end
    
    S.(fields_values_pairs{1,i}) = fields_values_pairs{2,i};
end