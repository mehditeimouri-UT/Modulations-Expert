function ErrorMsg = Check_Variable_Value_ME(var,varname,varargin)

% This function gets a variable and check that the assigned value(s) are
% correct according to some predefined rules.
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
%   var: The value assigned to variable
%   varname: The string which specifies the variable name
%   varargin: Some pairs of name and value that specify certain aspects of the error checking.
%       Possible name/value pairs are:
%           'type': 'scalar', 'vector', 'matrix'
%           'class': 'integer', 'real'
%           'size': [m n] that specifies the size
%           'minsize': [m n] that specifies the minimum acceptable size
%           'min': Minimum acceptable value
%           'max': Maximum acceptable value
%           'fixed-value': Fixed acceptable numeric value
%           'sum': Sum of the values of a vector
%           'min-prod': Minimum of the product of values in a vector
%           'possiblevalues': One of the predefined values that can be assigned
%           'issorted': 'ascend' , 'descend'
%           'mod': [p r] that specifies mod(value,p) should be r
%           'unique-values': A cell array, in which, the first input is the vector
%               that defines the allowed values and the second input is the
%               string to be displayed when the values are out of range.
%           'numel-min-max': [min max] values for number of elements in the
%               input vector
%           'matrix-min-max-channels': [c1 c2] that specifies the minimum
%               and maximum size of the lower dimension of the input matrix.
%           'matrix-channel-samples-min-max': [min max] values for number of elements in each channel of the
%               input matrix
%
% Ourputs:
%   ErrorMsg: Error messag, which is empty if there is no error.
%
% Revisions:
% 2020-Sep-01   function was created

%% Initialization
ErrorMsg = '';

%% Check for Errors
N = nargin;
N = (N-2)/2;
for j=1:N
    name = varargin{2*j-1};
    value = varargin{2*j};
    switch lower(name)
        case 'type'
            
            switch lower(value)
                case 'scalar'
                    if ~isscalar(var)
                        ErrorMsg = sprintf('%s should be scalar.',varname);
                        return;
                    end
                    
                case 'vector'
                    if ~isvector(var)
                        ErrorMsg = sprintf('%s should be a vector.',varname);
                        return;
                    end
                    
                case 'matrix'
                    if ~ismatrix(var)
                        ErrorMsg = sprintf('%s should be a matrix.',varname);
                        return;
                    end
                    
                otherwise
                    error('Unpredicted Error: The value input for name=''type'' in Check_Variable_Value_ME is not valid');
                    
            end
            
        case 'class'
            
            switch lower(value)
                case 'real'
                    if ~isreal(var)
                        ErrorMsg = sprintf('%s should have real values.',varname);
                        return;
                    end
                    
                case 'integer'
                    if any(mod(var,1)~=0)
                        ErrorMsg = sprintf('%s should have integer values.',varname);
                        return;
                    end
                    
                otherwise
                    error('Unpredicted Error: The value input for name=''class'' in Check_Variable_Value_ME is not valid');
                    
            end
            
        case 'size'
            
            if ~isequal(size(var),value)
                ErrorMsg = sprintf('The size of %s should be %dx%d.',varname,value(1),value(2));
                return;
            end
            
        case 'minsize'
            
            [m,n] = size(var);
            if m<value(1) || n<value(2)
                ErrorMsg = sprintf('The size of %s should be at least %dx%d.',varname,value(1),value(2));
                return;
            end
            
        case 'min'
            
            if any(min(var)<value)
                ErrorMsg = sprintf('The values of %s should be at least equal to %g.',varname,value);
                return;
            end
            
        case 'max'
            
            if any(max(var)>value)
                ErrorMsg = sprintf('The values of %s should be at most equal to %g.',varname,value);
                return;
            end
            
        case 'fixed-value'
            
            if ~isequal(var,value)
                ErrorMsg = sprintf('The value of %s should be fixed to %g.',varname,value);
                return;
            end
            
        case 'sum'
            
            if ~isequal(sum(var),value)
                ErrorMsg = sprintf('The sum of the values of %s should be equal to %g.',varname,value);
                return;
            end

        case 'min-prod'
            
            if prod(var)<value
                ErrorMsg = sprintf('The minimum of the products of values in %s should be at least to %g.',varname,value);
                return;
            end
            
        case 'possiblevalues'
            
            if ~any(cellfun(@(x)isequal(x,var),value))
                ErrorMsg = sprintf('The value of %s should be one of the pre-defined values.',varname);
                return;
            end
            
        case 'issorted'
            if ~isequal(var,sort(var,value))
                ErrorMsg = sprintf('Vector %s should be sorted with %sing order.',varname,value);
                return;
            end
            
        case 'mod'
            if any(mod(var,value(1))~=value(2))
                ErrorMsg = sprintf('The values for %s modulo %g should %g.',varname,value(1),value(2));
                return;
            end
            
        case 'unique-values'
            if ~isempty(setdiff(unique(var),value{1}))
                ErrorMsg = sprintf('The values of %s %s.',varname,value{2});
                return;
            end
            
        case 'numel-min-max'
            if numel(var)<value(1)
                ErrorMsg = sprintf('The number of elements in %s should be at least equal to %d.',varname,value(1));
                return;
            end
            
            if numel(var)>value(2)
                ErrorMsg = sprintf('The number of elements in %s should be at most equal to %d.',varname,value(2));
                return;
            end
            
        case 'matrix-min-max-channels'
            if min(size(var))<value(1)
                ErrorMsg = sprintf('The number of channels in %s should be at least equal to %d.',varname,value(1));
                return;
            end
            
            if min(size(var))>value(2)
                ErrorMsg = sprintf('The number of channels in %s should be at most equal to %d.',varname,value(2));
                return;
            end
            
        case 'matrix-channel-samples-min-max'

            if max(size(var))<value(1)
                ErrorMsg = sprintf('The number of elements in each cahnnel of %s should be at least equal to %d.',varname,value(1));
                return;
            end
            
            if max(size(var))>value(2)
                ErrorMsg = sprintf('The number of elements in each cahnnel %s should be at most equal to %d.',varname,value(2));
                return;
            end
            
            
        otherwise
            error('Unpredicted Error: The name input for Check_Variable_Value_ME is not valid');
            
            
    end
end
