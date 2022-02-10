% This function calculates constellation points for QAM modulation (M>=8).
%   Note: The function is taken from MATLAB library and is changed a little bit.
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
%   M: Modulation order (M>=8)
%
% Output:
%   constellation: 1xM vector of constellation points with unit energy.
%
% Revisions:
% 2020-Sep-05   function was created

function constellation = qam_constellation_ME(M)

% This function calculates constellation points for QAM (M>=8).

if( log2(M)/2 ~= floor(log2(M)/2) && log2(M) >3) % Cross constellation
    
    nbits  = log2(M);
    constellation = zeros(1,M);
    nIbits = (nbits + 1) / 2;
    nQbits = (nbits - 1) / 2;
    mI = 2^nIbits;
    mQ = 2^nQbits;
    for i = 0:M-1
        I_data  = fix(i/2^nQbits);
        Q_data = bitand( i, fix(((M-1)/(2^nIbits))));
        cplx_data = (2 * I_data + 1 - mI) + 1i*(-1 * (2 * Q_data + 1 - mQ));
        I_mag = abs(floor(real(cplx_data)));
        if(I_mag > 3 * (mI / 4))
            Q_mag = abs(floor(imag(cplx_data)));
            I_sgn = sign(real(cplx_data));
            Q_sgn = sign(imag(cplx_data));
            if(Q_mag > mQ/2)
                cplx_data = I_sgn*(I_mag - mI/2) + 1i*( Q_sgn*(2*mQ - Q_mag));
            else
                cplx_data = I_sgn*(mI - I_mag) + 1i*(Q_sgn*(mQ + Q_mag));
            end
        end
        
        constellation(i+1) =  real(cplx_data) + 1i*imag(cplx_data);
    end
    
else % Regular square QAM
    
    % Get the QAM points, for 1 quadrant, expand to all 4 quadrants.
    if M==8
        Const = [1+1i ; 3+1i];
    else
        N = sqrt(M/4);
        Const = reshape(repmat(1:2:2*N-1,N,1)+1i*repmat((1:2:2*N-1)',1,N),[],1);
    end
    newConst = [Const; conj(Const); -Const; -conj(Const) ];
    
    
    % sort
    constellation = zeros(1,M);
    for k = 1:M
        % find the elements with the smallest real component
        ind1 = find(real(newConst) == min(real(newConst)));
        % of those, find the element with the largest imaginary component
        tmpArray = -1i*inf * ones(size(newConst));
        tmpArray(ind1) = newConst(ind1);
        ind2 = find(imag(tmpArray) == max(imag(tmpArray)));
        
        constellation(k)= newConst(ind2);
        %get rid of the old point
        newConst(ind2) = [];
    end
end

% Scale to unit energy
energy = mean(abs(constellation).^2);
constellation = constellation/sqrt(energy);