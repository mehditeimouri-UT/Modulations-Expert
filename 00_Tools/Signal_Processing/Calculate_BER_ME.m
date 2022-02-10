% This function takes two bitstream x and y, which is the estimation of x, and calculates the bit error
% rate.
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
%   x: Original bitstream as a row vector
%   y: Estimated bitstream as a row vector
%       Note: x and y may  be unsynchronized. 
%
% Outputs:
%   dt: The values of delay in y.
%       Note: When dt<0, in fact, x has delay. 
%   L: Length of common parts in x and y.
%   numerr: The number of bit-errors in L bits.
%   BER: Estimated bit error rate (numerr/L)
%
% Revisions:
% 2020-Sep-14   function was created

function [dt,L,numerr,BER] = Calculate_BER_ME(x,y)

%% Synchronization
r = xcorr(2*x-1,2*y-1);
[~,idx] = max(r);
dt = (length(r)+1)/2-idx;
if dt>=0
    input = x;
    output = y(1+dt:end);
else
    input = x(1-dt:end);
    output = y;
end

%% Calculate BER
L = min(length(input),length(output));
numerr = nnz(input(1:L)-output(1:L));
BER = numerr/L;