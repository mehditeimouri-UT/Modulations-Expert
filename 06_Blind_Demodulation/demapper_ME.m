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

function [s,v] = demapper_ME(y)

% This function implements digital demapping for baseband symbols of digital modulations. Demapping is performed
% based on the demodulation information in global parameter RxPrms.
%
% Inputs
%   y: baseband symbols of modulated signal with length L
%       Note: For FSK, y is the outputs of correlators with size RxPrms.MxL
%
% Outputs
%   s: A row vector representing message symbols with length L
%   v: A binary row vector representing message bits with length L*log2(RxPrms.M)
%
%       Note: For DPSK modulation, lengths of s and v are L-1 and
%       (L-1)*log2(RxPrms.M). 

%% Global Parameters
global RxPrms

%% Perform Modulation
switch lower(RxPrms.ModType)
    case 'fsk'
        [s,v] = fsk_demapper_ME(y);
    case 'psk'
        [s,v] = psk_demapper_ME(y);
    case 'dpsk'
        [s,v] = dpsk_demapper_ME(y);
    case 'oqpsk'
        [s,v] = oqpsk_demapper_ME(y);
    case 'qam'
        [s,v] = qam_demapper_ME(y);
    otherwise
        error('Unknown modulation type.');
end


%% FSK Demapper
function [s,v] = fsk_demapper_ME(y)

% This function implements frequency-shift keying demapping
%
% Inputs
%   y: Outputs of correlators with size RxPrms.MxL
%
% Outputs
%   s: A binary row vector representing message symbols with length L
%   v: Empty matrix 

% Global Parameters
global RxPrms

% Demapping
[~,s] = max(y,[],1);
s = RxPrms.symbolmap(s);
v = [];

%% PSK Demapper
function [s,v] = psk_demapper_ME(y)

% This function implements phase-shift keying demapping
%
% Inputs
%   y: baseband symbols of modulated signal with length L
%
% Outputs
%   s: A binary row vector representing message symbols with length L
%   v: A binary row vector representing message bits with length L*log2(RxPrms.M)

% Global Parameters
global RxPrms

% Normalization
y = y(:).'./sqrt(mean(abs(y).^2));

% Hard Decision and Demapping
[~,s] = min(abs(repmat(y,RxPrms.M,1)-repmat(RxPrms.Constellation(:),1,numel(y))));
s = RxPrms.symbolmap(s);
v = reshape(de2bi(s,log2(RxPrms.M),'left-msb')',1,[]);

%% DPSK Demapper
function [s,v] = dpsk_demapper_ME(y)

% This function implements differential phase-shift keying demapping
%
% Inputs
%   y: baseband symbols of modulated signal with length L
%
% Outputs
%   s: A binary row vector representing message symbols with length (L-1)
%   v: A binary row vector representing message bits with length (L-1)*log2(RxPrms.M)

% Global Parameters
global RxPrms

% Differential Phase Calculation
y = y(2:end).*conj(y(1:end-1));

% Normalization
y = y(:).'./sqrt(mean(abs(y).^2));

% Hard Decision and Demapping
[~,s] = min(abs(repmat(y,RxPrms.M,1)-repmat(RxPrms.Constellation(:),1,numel(y))));
s = RxPrms.symbolmap(s);
v = reshape(de2bi(s,log2(RxPrms.M),'left-msb')',1,[]);

%% OQPSK Demapper
function [s,v] = oqpsk_demapper_ME(y)

% This function implements offset quadrature phase-shift keying demapping
%   Note: It is assumed that inphase and quadrature components are
%   alligend. So, demodulation is same as psk. 
%
% Inputs
%   y: baseband symbols of modulated signal with length L
%
% Outputs
%   s: A binary row vector representing message symbols with length L
%   v: A binary row vector representing message bits with length L*log2(RxPrms.M)

% Global Parameters
global RxPrms

% Normalization
y = y(:).'./sqrt(mean(abs(y).^2));

% Hard Decision and Demapping
[~,s] = min(abs(repmat(y,RxPrms.M,1)-repmat(RxPrms.Constellation(:),1,numel(y))));
s = RxPrms.symbolmap(s);
v = reshape(de2bi(s,log2(RxPrms.M),'left-msb')',1,[]);

%% QAM Demapper
function [s,v] = qam_demapper_ME(y)

% This function implements quadrature amplitude demapping
%
% Inputs
%   y: baseband symbols of modulated signal with length L
%
% Outputs
%   s: A binary row vector representing message symbols with length L
%   v: A binary row vector representing message bits with length L*log2(RxPrms.M)

% Global Parameters
global RxPrms

% Normalization
y = y(:).'./sqrt(mean(abs(y).^2));

% Hard Decision and Demapping
[~,s] = min(abs(repmat(y,RxPrms.M,1)-repmat(RxPrms.Constellation(:),1,numel(y))));
s = RxPrms.symbolmap(s);
v = reshape(de2bi(s,log2(RxPrms.M),'left-msb')',1,[]);