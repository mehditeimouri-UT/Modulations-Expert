% This function implements QAM/PSK/DPSK receiver including the time and frequency synchronizers. 
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
%   s: Output symbols
%   v: Output bits
%   possible_phasertos: Phase rotation used in making rows v 
%
% Revisions:
% 2020-Dec-10   function was created

function [s,v,possible_phasertos] = QAM_PSK_Receiver_ME(r,ConvergenceDelay,ShowFigures)

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

%% Symbol Synchronization
r_s = r(round(1:RxPrms.sps/2:length(r))).';
if ShowFigures
    figure(h)
    subplot(2,2,1)
    scatterplot_ME(r)
    title('Matched Filter Output: 2 Samples/Symbol');
end

rxSym = ZeroCrossingSymSync_ME(r_s,2);

if ShowFigures
    figure(h)
    subplot(2,2,2)
    scatterplot_ME(rxSym(1+ConvergenceDelay:end))
    title('Symbol Synchronization');
end

%% Coarse Carrier Synchronization
freqEst = CoarseFrequencyEstimator_ME(rxSym,RxPrms.ModType,RxPrms.M,RxPrms.phaserot,RxPrms.BR,RxPrms.BR/1000);
rxSym = exp(-1i*2*pi*freqEst/RxPrms.BR*(0:length(rxSym)-1)').*rxSym;

if ShowFigures
    figure(h)
    subplot(2,2,3)
    scatterplot_ME(rxSym(1+ConvergenceDelay:end))
    title('Coarse Carrier Synchronization')
end

%% Fine Carrier Synchronization
rxSym = CarrierSynchronizer_ME(rxSym,RxPrms.ModType,RxPrms.M,RxPrms.phaserot,1);
if ShowFigures
    figure(h)
    subplot(2,2,4)
    scatterplot_ME(rxSym(1+ConvergenceDelay:end))
    title('Fine Carrier Synchronization')
end

%% Demapping
s = rxSym(1+ConvergenceDelay:end);
[~,v,possible_phasertos] = demapper_PhaseAmbiguity_ME(s);