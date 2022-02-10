% Raised cosine FIR filter design for fractional sps
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
%   B = rcosdesign_fr_MT(BETA, SPAN, SPS, SHAPE) returns a normal raised cosine
%       FIR filter when you set SHAPE to 'normal'. When you set SHAPE to
%       'sqrt', the function returns a square root raised cosine filter.
%
% Revisions:
% 2020-Dec-10   function was created

function b = rcosdesign_fr_ME(beta, span, sps, shape)

% Argument error checking
narginchk(4,4);

sps_i = round(sps);
if mod(sps_i*span, 2) == 1
    sps_i = sps+1;
end

% Design the raised cosine filter
delay = span*sps_i/2;
t = (-delay:delay)/sps;

if strncmp(shape, 'normal', 1)
    % Design a normal raised cosine filter
    
    % Find non-zero denominator indices
    denom = (1-(2*beta*t).^2);
    idx1 = find(abs(denom) > sqrt(eps));
    
    % Calculate filter response for non-zero denominator indices
    b(idx1) = sinc(t(idx1)).*(cos(pi*beta*t(idx1))./denom(idx1))/sps;
    
    % fill in the zeros denominator indices
    idx2 = 1:length(t);
    idx2(idx1) = [];
    
    b(idx2) = beta * sin(pi/(2*beta)) / (2*sps);
    
else
    % Design a square root raised cosine filter
    
    % Find mid-point
    idx1 = find(t == 0);
    if ~isempty(idx1),
        b(idx1) = -1 ./ (pi.*sps) .* (pi.*(beta-1) - 4.*beta );
    end
    
    % Find non-zero denominator indices
    idx2 = find(abs(abs(4.*beta.*t) - 1.0) < sqrt(eps));
    if ~isempty(idx2),
        b(idx2) = 1 ./ (2.*pi.*sps) ...
            * (    pi.*(beta+1)  .* sin(pi.*(beta+1)./(4.*beta)) ...
            - 4.*beta     .* sin(pi.*(beta-1)./(4.*beta)) ...
            + pi.*(beta-1)  .* cos(pi.*(beta-1)./(4.*beta)) ...
            );
    end
    
    % fill in the zeros denominator indices
    ind = 1:length(t);
    ind([idx1 idx2]) = [];
    nind = t(ind);
    
    b(ind) = -4.*beta./sps .* ( cos((1+beta).*pi.*nind) + ...
        sin((1-beta).*pi.*nind) ./ (4.*beta.*nind) ) ...
        ./ (pi .* ((4.*beta.*nind).^2 - 1));
    
end

% Normalize filter energy
b = b / sqrt(sum(b.^2));