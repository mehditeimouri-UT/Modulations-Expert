% This function implements digital demapping for baseband symbols of digital modulations. Demapping is performed
% based on the demodulation information in global parameter RxPrms.
%
%   Note: Demapping is performed with various possible constant phase rotation. 
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
% Inputs
%   y: baseband symbols of modulated signal with length L
%       Note: For FSK, y is the outputs of correlators with size RxPrms.MxL
%
% Outputs
%   s: A matrix matrix, each row representing message symbols with length L
%   for corresponding phase rotation
%   v: A binary matrix, each row representing message bits with length
%   L*log2(RxPrms.M) for corresponding phase rotation
%   possible_phasertos: Phase rotation used in making rows of s and v 
%
%       Note: For DPSK modulation, length of rows are L-1 and
%       (L-1)*log2(RxPrms.M). 
%
% Revisions:
% 2020-Dec-10   function was created

function [s,v,possible_phasertos] = demapper_PhaseAmbiguity_ME(y)

%% Global Parameters
global RxPrms

%% Initialization
L0 = length(y);
switch lower(RxPrms.ModType)

    case 'psk'
        possible_phasertos = (0:2*pi/RxPrms.M:(RxPrms.M-1)*2*pi/RxPrms.M);

    case 'qam'
        if RxPrms.M==8 || RxPrms.M==32 || RxPrms.M==128
            possible_phasertos = 0:pi/8:7*pi/4;
        else
            possible_phasertos = (0:pi/2:3*pi/2);
        end
        
    case 'oqpsk'
        possible_phasertos = 0:pi/2:3*pi/2;
        
    otherwise
        possible_phasertos = 0;
end

if strcmpi(RxPrms.ModType,'dpsk')
    s = zeros(length(possible_phasertos),L0-1);
    v = zeros(length(possible_phasertos),(L0-1)*log2(RxPrms.M));
else
    s = zeros(length(possible_phasertos),L0);
    v = zeros(length(possible_phasertos),L0*log2(RxPrms.M));
end

%% Demapping with various phase rotations
for i=1:length(possible_phasertos)
    [s(i,:),v(i,:)] = demapper_ME(exp(1i*possible_phasertos(i))*y);
end
