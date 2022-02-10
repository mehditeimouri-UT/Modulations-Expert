% This function does coarse frequency estimation on recieved linearly modulated signal.
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
%   [1] Nakagawa, T., Matsui, M., Kobayashi, T., Ishihara, K., Kudo, R., Mizoguchi, M., and Y. Miyamoto. "Non-data-aided wide-range frequency offset estimator for QAM optical coherent receivers", 
%       Optical Fiber Communication Conference and Exposition (OFC/NFOEC), 2011 and the National Fiber Optic Engineers Conference , March, 2011, pp. 1–3.
%   [2] Wang, Y., Shi. K., and E. Serpedin. "Non-Data-Aided Feedforward Carrier Frequency Offset Estimators for QAM Constellations: A Nonlinear Least-Squares Approach", 
%       EURASIP Journal on Advances in Signal Processing, Vol. 13, 2004, pp. 1993–2001.
%
% Inputs:
%   r: Complex baseband signal with frequency deviation
%   mod_type: Modulation type ('qam'|'psk'|'dpsk'|'oqpsk')
%   M: Modulation order
%   phase_rot: Phase rotation used in transmitter constellation
%   fs: Sampling frequency (Hz)
%   freq_res: Frequency resolution (Hz)
%
% Outputs: 
%   df: Frequency deviation (Hz) 
%
% Revisions:
% 2020-Dec-10   function was created

function df = CoarseFrequencyEstimator_ME(r,mod_type,M,phase_rot,fs,freq_res)

%% Check for error
if fs<2*freq_res
    error('Sample rate is too small!');
end

%% Parameters setting
Nfft = min(2^ceil(log2(fs/freq_res)),length(r));
L = length(r);
r = reshape(r,1,[]);

%% Select Signal Exponent
switch lower(mod_type)
    case {'psk','oqpsk'}
        
        exponent = M;
        
    case 'dpsk'

        if phase_rot==pi/4
            exponent = 8;
        else
            exponent = M;
        end
        
    case 'qam'
        
        exponent = 4;
        
    otherwise
        error('Modulation type is not supported!');
end
r = r.^exponent;
R = zeros(1,Nfft);

%% FFT Calculation
for i=1:L/Nfft
    R = R+abs(fft(r((i-1)*Nfft+(1:Nfft))));
end

if mod(L/Nfft,1)~=0
    R = R+abs(fft(r(end-Nfft+1:end)));
end

%% Find Maximum Frequency Index
[~, maxIdx] = max(fftshift(R));
offsetIdx = maxIdx - Nfft/2;  % translate to -Fs/2 : Fs/2

%% Map offset index to a frequency value.
df = fs/Nfft*(offsetIdx-1)/exponent;

