% This function compensates for frequency offsets and phase rotations.
% The function uses a closed-loop PLL approach to reduce  frequency offset and phase rotation.
% The phase error is generated from a hard decision of the received signal.
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
% References:
%   [1] Rice, Michael. Digital Communications: A Discrete-Time Approach. Upper Saddle River, NJ: Prentice Hall, 2009, pp. 359–393.
%   [2] Huang, Zhijie, Zhiqiang Yi, Ming Zhang, and Kuang Wang. "8PSK Demodulation for New Generation DVB-S2." 
%       International Conference on Communications, Circuits and Systems, 2004. ICCCAS 2004. Vol. 2, 2004, pp. 1447–1450.
%
% Inputs:
%   x: Complex baseband signal with frequency deviation
%   mod_type: Modulation type ('qam'|'psk'|'dpsk'|'oqpsk')
%   M: Modulation order
%   phase_rot: Phase rotation used in transmitter constellation
%   sps: sample per symbol
%
% Outputs:
%   y: Output symbols of synchronizer
%   phaseEstimate: Estimation of the phase errors in radians
%
% Revisions:
% 2020-Dec-10   function was created

function [y,phaseEstimate] = CarrierSynchronizer_ME(x,mod_type,M,phase_rot,sps)

%% Main Synchronization Parameters
DampingFactor = 0.7;
NormalizedLoopBandwidth = 0.001;

%% Initialize Synchronizer
switch lower(mod_type)
    case 'psk'
        
        if M==2
            obj.Modulation = 'BPSK';
        elseif M==4
            obj.Modulation = 'QPSK';
        elseif M==8
            obj.Modulation = '8PSK';
        end
        obj.CustomPhaseOffset = phase_rot;
        
    case 'dpsk'
        
        if ~ismember(M,[2 4])
            error('Modulation type is not supported!');
        end
        if phase_rot==pi/4
            obj.Modulation = '8PSK';
        elseif M==2
            obj.Modulation = 'BPSK';
        elseif M==4
            obj.Modulation = 'QPSK';
        end
        obj.CustomPhaseOffset = 0;
        
    case 'qam'
        
        obj.Modulation = 'QAM';
        obj.CustomPhaseOffset = phase_rot;
            
    case 'oqpsk'
        
        obj.Modulation = 'QPSK';
        obj.CustomPhaseOffset = phase_rot;

    otherwise
        
        error('Modulation type is not supported!');
        
end

% Select error generation based on modulation and gain value
% Kp: Slope of phase detector S-Curve linear range
switch obj.Modulation
    case { 'QAM' , 'QPSK' }
        obj.pPED = 1;
        obj.pPhaseErrorDetectorGain = 2; % Kp
    case {'BPSK' }
        obj.pPED = 2;
        obj.pPhaseErrorDetectorGain = 1; % Kp
    case '8PSK'
        obj.pPED = 3;
        obj.pPhaseErrorDetectorGain = 1; % Kp
end

% Set loop gains
obj.DampingFactor = DampingFactor;
obj.NormalizedLoopBandwidth = NormalizedLoopBandwidth;
obj.SamplesPerSymbol = sps;
obj = CalculateLoopGains(obj);

% Invert DDS output to correct not estimate
obj.pDigitalSynthesizerGain = -1;

% Reset parameters and objects to initial states
obj.pLoopFilterState = 0;
obj.pIntegFilterState = 0;
obj.pDDSPreviousInput = 0;
obj.pPhase = 0;
obj.pPreviousSample = 0;

%% Synchronization
% Copying obj parameters for speed improvement
loopFiltState = obj.pLoopFilterState;
integFiltState = obj.pIntegFilterState;
DDSPreviousInp = obj.pDDSPreviousInput;
previousSample = obj.pPreviousSample;

% Preallocate outputs
y = zeros(size(x));
phaseCorrection = zeros(size(x));

% PLL Loop
switch obj.pPED
    case 1 % QAM and QPSK
        
        for k = 1:length(x)
            
            % Find Phase Error
            phErr = sign(real(previousSample)).*imag(previousSample)...
                - sign(imag(previousSample)).*real(previousSample);
            
            % Phase accumulate and correct
            y(k) = x(k)*exp(1i*obj.pPhase);
            
            % Loop Filter
            loopFiltOut = phErr*obj.pIntegratorGain + loopFiltState;
            loopFiltState = loopFiltOut;
            
            % Direct digital synthesizer implemented as an integrator
            DDSOut = DDSPreviousInp + integFiltState;
            integFiltState = DDSOut;
            DDSPreviousInp = phErr*obj.pProportionalGain+loopFiltOut;
            
            obj.pPhase = obj.pDigitalSynthesizerGain*DDSOut;
            
            phaseCorrection(k) = obj.pPhase;
            previousSample = y(k);
            
        end
        
    case 2 % BPSK
        
        for k = 1:length(x)
            
            % Find Phase Error
            phErr = sign(real(previousSample))*imag(previousSample);
            
            % Phase accumulate and correct
            y(k) = x(k)*exp(1i*obj.pPhase);
            
            % Loop Filter
            loopFiltOut = phErr*obj.pIntegratorGain + loopFiltState;
            loopFiltState = loopFiltOut;
            
            % Direct digital synthesizer implemented as an integrator
            DDSOut = DDSPreviousInp + integFiltState;
            integFiltState = DDSOut;
            DDSPreviousInp = phErr*obj.pProportionalGain+loopFiltOut;
            
            obj.pPhase = obj.pDigitalSynthesizerGain*DDSOut;
            
            phaseCorrection(k) = obj.pPhase;
            previousSample = y(k);
            
        end
        
    case 3 % 8PSK
        
        K = sqrt(2)-1;
        for k = 1:length(x)
            
            % Find Phase Error
            if abs(real(previousSample)) >= abs(imag(previousSample))
                phErr = sign(real(previousSample))*imag(previousSample) - ...
                    sign(imag(previousSample))*real(previousSample)*K;
            else
                phErr = sign(real(previousSample))*imag(previousSample)*K -...
                    sign(imag(previousSample))*real(previousSample);
            end
            
            % Phase accumulate and correct
            y(k) = x(k)*exp(1i*obj.pPhase);
            
            % Loop Filter
            loopFiltOut = phErr*obj.pIntegratorGain + loopFiltState;
            loopFiltState = loopFiltOut;
            
            % Direct digital synthesizer implemented as an integrator
            DDSOut = DDSPreviousInp + integFiltState;
            integFiltState = DDSOut;
            DDSPreviousInp = phErr*obj.pProportionalGain+loopFiltOut;
            
            obj.pPhase = obj.pDigitalSynthesizerGain*DDSOut;
            
            phaseCorrection(k) = obj.pPhase;
            previousSample = y(k);
            
        end
        
end

% Update previous sample and phase rotate as desired
y = y*exp(1i*obj.pActualPhaseOffset);

% Changing sign to convert from correction value to estimate
phaseEstimate = -real(phaseCorrection+obj.pActualPhaseOffset);

%Updating states: In cuurent version it is not necessary
obj.pLoopFilterState = loopFiltState;
obj.pIntegFilterState = integFiltState;
obj.pPreviousSample = complex(previousSample);
obj.pDDSPreviousInput = DDSPreviousInp;


function obj = CalculateLoopGains(obj)

% Calculate loops gains and filter coefficient.
%   Refer to equation C.61 of Appendix C of "Digital Communications - A Discrete-Time Approach" by Michael Rice

PhaseRecoveryLoopBandwidth = obj.NormalizedLoopBandwidth *obj.SamplesPerSymbol;

% K0
PhaseRecoveryGain = obj.SamplesPerSymbol;

theta = PhaseRecoveryLoopBandwidth/((obj.DampingFactor + 0.25/obj.DampingFactor)*obj.SamplesPerSymbol);
d = 1 + 2*obj.DampingFactor*theta + theta*theta;

% K1
obj.pProportionalGain = (4*obj.DampingFactor*theta/d)/(obj.pPhaseErrorDetectorGain*PhaseRecoveryGain);

% K2
obj.pIntegratorGain = (4/obj.SamplesPerSymbol*theta*theta/d)/(obj.pPhaseErrorDetectorGain*PhaseRecoveryGain);

% Phase offset adjustment
switch obj.Modulation
    case 'QPSK'
        obj.pActualPhaseOffset = obj.CustomPhaseOffset-pi/4;
    case '8PSK'
        obj.pActualPhaseOffset = obj.CustomPhaseOffset-pi/8;
    otherwise
        obj.pActualPhaseOffset = obj.CustomPhaseOffset;
end
