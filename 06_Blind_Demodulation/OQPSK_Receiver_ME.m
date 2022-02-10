% This function implements OQPSK receiver including the time and frequency synchronizers. 
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
%   r: Complex baseband recieved signal samples
%   ConvergenceDelay: Index of the first symbol of demodulated data put in the output (due to convergence delay of synchronizers)
%   ShowFigures: If true, performace plot of synchronizers are plotted
%
% Outputs: 
%   s1 and s2: Output symbols
%   v1 and v2: Output bits
%   possible_phasertos: Phase rotation used in making rows of s and v 
%
% Revisions:
% 2020-Dec-13   function was created

function [s1,s2,v1,v2,possible_phasertos] = OQPSK_Receiver_ME(r,ConvergenceDelay,ShowFigures)

% This function implements OQPSK receiver including the time and frequency synchronizers. 
%
% Inputs:
%   r: Complex baseband recieved signal samples
%   ConvergenceDelay: Index of the first symbol of demodulated data put in the output (due to convergence delay of synchronizers)
%   ShowFigures: If true, performace plot of synchronizers are plotted
%
% Outputs: 
%   s1 and s2: Output symbols
%   v1 and v2: Output bits
%   possible_phasertos: Phase rotation used in making rows of s and v 

%% Global Parameters
global RxPrms

%% Parameters
if nargin<3
    ShowFigures = false;
end
if ShowFigures
    h = figure;
    set(h,'Name',sprintf('Results of Blind Demodulation'),'NumberTitle','off'); 
end

%% Matched Filter
r = conv(r,RxPrms.h);
r = r(1+RxPrms.D:end-RxPrms.D);

%% Coarse Carrier Synchronization
r_s = r(round(1+RxPrms.sps/2:RxPrms.sps/4:length(r))).';

freqEst = CoarseFrequencyEstimator_ME(r_s,RxPrms.ModType,RxPrms.M,RxPrms.phaserot,4*RxPrms.BR,RxPrms.BR/1000);
rxSym = exp(-1i*2*pi*freqEst/(4*RxPrms.BR)*(0:length(r_s)-1)').*r_s;
if ShowFigures
    figure(h)
    subplot(2,2,1)
    scatterplot_ME(rxSym(1+ConvergenceDelay:end))
    title('After Coarse Carrier Synchronization')
end

%% Fine Carrier Synchronization
rxSymFinal = CarrierSynchronizer_ME(rxSym,RxPrms.ModType,RxPrms.M,RxPrms.phaserot,4);
if ShowFigures
    figure(h)
    subplot(2,2,2)
    scatterplot_ME(rxSymFinal(1+ConvergenceDelay:end))
    title('Fine Carrier Synchronization')
end

%% Symbol Synchronization
% First possible data configuration
rxSymFinal1 = real(rxSymFinal(1:end-2))+1i*imag(rxSymFinal(1+2:end));
rxSym1 = rxSymFinal1(1:2:end);
rxSym1 = ZeroCrossingSymSync_ME(rxSym1,2);
if ShowFigures
    figure(h)
    subplot(2,2,3)
    scatterplot_ME(rxSym1(1+ConvergenceDelay:end))
    title('Symbol Synchronization I')
end

% Second possible data configuration
rxSymFinal2 = 1i*imag(rxSymFinal(1:end-2))+real(rxSymFinal(1+2:end));
rxSym2 = rxSymFinal2(1:2:end);
rxSym2 = ZeroCrossingSymSync_ME(rxSym2,2);
if ShowFigures
    figure(h)
    subplot(2,2,4)
    scatterplot_ME(rxSym2(1+ConvergenceDelay:end))
    title('Symbol Synchronization II')
end

%% Demapper
% First possible data configuration
s1 = rxSym1(1+ConvergenceDelay:end);
[~,v1,~] = demapper_PhaseAmbiguity_ME(s1);

% Second possible data configuration
s2 = rxSym2(1+ConvergenceDelay:end);
[~,v2,possible_phasertos] = demapper_PhaseAmbiguity_ME(s2);