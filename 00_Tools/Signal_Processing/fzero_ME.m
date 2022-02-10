% This function calculates roots of a function f in region [x1 x2] with tolerance tol.
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
% For real signals, PSD_ME returns the one-sided PSD by default; for complex signals,
%   it returns the two-sided PSD.  
%       Note: A one-sided PSD contains the total power of the input signal.
%
% Inputs:
%   f: Function handle
%   x1: Start of Interval
%   x1: End of Interval
%   tol: tolerance
%
% Outputs:
%   x: root of f in interval [x1 x2]
%
% Revisions:
% 2020-Dec-10   function was created

function x = fzero_ME(f,x1,x2,tol)

y1 = f(x1);
y2 = f(x2);
while (abs(x1-x2)>tol)
    x = (x1+x2)/2;
    y = f(x);
    
    if y1*y<=0
        x2 = x;
        y2 = y;
    elseif y2*y<=0
        x1 = x;
        y1 = y;
    else
        error('Initial points are not suitable!');
    end
    
end

x = (x1+x2)/2;