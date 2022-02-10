% This function compensates for timing frequency and phase offsets between a transmitter clock and a receiver clock. 
% The function uses a phase-locked loop (PLL) approach to recover the symbol timing  phase of the sample input. 
% It works for PSK and QAM constellations.
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
%   Note: The method is not recommended for constellations that have points with either a zero in-phase or quadrature component.
%
%   The symbol synchronizer PLL consists of a piecewise parabolic
%   interpolator in a Farrow structure, a timing error detector (TED), a
%   proportional-plus-integral (PI) loop filter, and a modulo-1 counter
%   interpolation controller. The proportional gain (K1) and integrator
%   gain (K2) of the loop filter are calculated based on the
%   SamplesPerSymbol (SPS), DampingFactor (zeta), NormalizedLoopBandwidth
%   (BnTs) and DetectorGain (Kp) properties as follows (refer to page 736
%   in [1]):
% 
%      theta = BnTs/SPS/(zeta + 0.25/zeta);
%      K1 = (4*zeta*theta)  / (1 + 2*zeta*theta + theta^2) / (-Kp);
%      K2 = (4*theta*theta) / (1 + 2*zeta*theta + theta^2) / (-Kp);
%
%   References: 
%       [1] Michael Rice, Digital Communications - A Discrete-Time Approach.
%           New York: Prentice Hall, 2008.
%
% Inputs:
%   x: Complex baseband samples of modulated signal
%   sps: Samples per symbol
%
% Outputs:
%   y: Output symbols of synchronizer
%
% Revisions:
% 2020-Dec-10   function was created

function y = ZeroCrossingSymSync_ME(x,sps)

%% Main Synchronization Parameters
if sps<2
    error('Samples per symbol should be greater than one!');
end
DampingFactor = 1;
NormalizedLoopBandwidth = 0.01;
DetectorGain = 2.7;

%% Derive proportional gain (K1) and integrator gain (K2) in the loop filter
% Refer to (C.56) & (C.57) on page 736 in Rice's book [1].
zeta = DampingFactor;
BnTs = NormalizedLoopBandwidth;
Kp = DetectorGain;
K0 = -1;

theta = BnTs/sps/(zeta + 0.25/zeta);
d  = (1 + 2*zeta*theta + theta^2) * K0 * Kp;
obj.pProportionalGain = (4*zeta*theta) /d;
obj.pIntegratorGain   = (4*theta*theta)/d;

%% Initialize PLL related properties
obj.pInputFrameLen = length(x);
obj.pSPS = sps;
obj.pLoopFilterState   = 0;
obj.pLoopPreviousInput = 0;
obj.pStrobe = false;
obj.pNumStrobe = 0;
obj.pStrobeHistory = false(1, obj.pSPS);
obj.pMu = 0;
obj.pNCOCounter = 0;
obj.pTimingError = zeros(obj.pInputFrameLen,1);
obj.pInterpFilterState = zeros(3,1);
obj.pTEDBuffer = zeros(1,obj.pSPS);
obj.maxOutputSize = ceil(obj.pInputFrameLen/obj.pSPS*1.1);
obj.pSymbolHolder = zeros(obj.maxOutputSize,1);
alpha = 0.5;
obj.pInterpFilterCoeff = ...
        [ 0,       0,         1,       0;      % Constant
         -alpha, 1+alpha, -(1-alpha), -alpha;  % Linear
          alpha,  -alpha,    -alpha,   alpha]; % Quadratic
      
%% Synchronization Loop
for i = 1 : obj.pInputFrameLen % Process input frame sample-by-sample
    obj.pTimingError(i) = obj.pMu;
    obj.pNumStrobe = obj.pNumStrobe + obj.pStrobe;
    
    % Refer to Figure 8.4.2 on page 449 in Rice's book [1].
    
    % Piecewise parabolic interpolator in Farrow structure with alpha
    % = 0.5. Refer to (8.72)-(8.73) on page 468 and Figure 8.4.16 on
    % page 471 in Rice's book [1].
    xSeq = [x(i); obj.pInterpFilterState];
    intOut = sum((obj.pInterpFilterCoeff * xSeq) .* [1; obj.pMu; obj.pMu^2]);
    obj.pInterpFilterState = xSeq(1:3);
    
    if obj.pStrobe % Interpolation output as symbols
        obj.pSymbolHolder(obj.pNumStrobe) = intOut;
    end
    
    % Timing error detector (TED)
    [e,obj] = ZeroCrossingTED(obj, intOut);
    
    % Refer to page 490-494 in Rice's book [1] for stuffing and skipping
    switch sum([obj.pStrobeHistory(2:end), obj.pStrobe])
        case 0
            % Skip current sample if NO strobe across N samples, i.e.,
            % obj.pStrobeHistory(2:end) = [0, 0, ..., 0] & obj.pStrobe = 0
        case 1
            % Shift TED buffer regularly if ONE strobe across N samples, i.e.,
            obj.pTEDBuffer = [obj.pTEDBuffer(2:end), intOut];
        otherwise % > 1
            % Stuff a missing sample if TWO strobes across N samples, i.e.,
            % obj.pStrobeHistory(2:end) = [1, 0, ..., 0] & obj.pStrobe = 1
            obj.pTEDBuffer = [obj.pTEDBuffer(3:end), 0, intOut];
            
    end  % End of TED
    
    % Loop filter
    loopFiltOut = obj.pLoopPreviousInput + obj.pLoopFilterState;
    v = e*obj.pProportionalGain + loopFiltOut;
    obj.pLoopFilterState = loopFiltOut;
    obj.pLoopPreviousInput = e*obj.pIntegratorGain;
    
    % Interpolation controller
    obj = interpControl(obj, v);
    
end
y = obj.pSymbolHolder(1:obj.pNumStrobe, 1);

function [e,obj] = ZeroCrossingTED(obj, x)

% TED calculation occurs on a strobe
if obj.pStrobe && all(~obj.pStrobeHistory(2:end))
    % The above condition allows TED update after a skip. If we want
    % TED update to happen only at regular strobings, need to check
    % obj.pStrobeHistory(1) == true in addition to the condition above.
    
    % Calculate the midsample point for odd or even samples per symbol
    t1 = obj.pTEDBuffer(end/2 + 1 - rem(obj.pSPS,2));
    t2 = obj.pTEDBuffer(end/2 + 1);
    midSample = (t1+t2)/2;
    e = real(midSample) * (sign(real(obj.pTEDBuffer(1))) - sign(real(x))) + ...
        imag(midSample) * (sign(imag(obj.pTEDBuffer(1))) - sign(imag(x)));
else
    e = 0;
end

function obj = interpControl(obj, v)

% Modulo-1 counter interpolation controller which generates/updates
% strobe signal (obj.pStrobe) and fractional interpolation interval
% (obj.pMu). Refer to Section 8.4.3 and Figure 8.4.19 in Rice's book [1].

W = v + 1/obj.pSPS; % W should be small when locked
obj.pStrobeHistory = [obj.pStrobeHistory(2:end), obj.pStrobe];
obj.pStrobe = (obj.pNCOCounter < W); % Check if a strobe
if obj.pStrobe % Update mu if a strobe
    obj.pMu = obj.pNCOCounter / W;
end
obj.pNCOCounter = mod(obj.pNCOCounter - W, 1); % Update counter