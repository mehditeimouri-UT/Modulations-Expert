% This function calculates constellation map for 'fsk', 'psk', 'dpsk', 'oqpsk', 'qam', 'ask' modulations.
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
%   ModType: Modulation type ('fsk', 'psk', 'dpsk', 'oqpsk', 'qam', 'ask')
%   M: Modulation order
%
% Output:
%   MAP: 1xM vector of constellation map for modulation
%
% Revisions:
% 2020-Sep-05   function was created

function MAP = bin2gray_ME(ModType,M)

switch lower(ModType)

    case {'fsk','psk','dpsk','oqpsk','ask'}

        % Calculate Gray table
        j = (0:M-1);
        MAP = bitxor(j,bitshift(j,-1));

    case {'qam'}

        k = log2(M); % Number of bits per symbol
        MAP = (0:M-1)'; % Binary mapping to be Gray converted
        if rem(k,2) % non-square constellation

            kI = (k+1)/2;
            kQ = (k-1)/2;

            symbolI = bitshift(MAP,-kQ);
            symbolQ = bitand(MAP,bitshift(M-1,-kI));

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < kI
                tempI = symbolI;
                tempI = bitshift(tempI,-i);
                symbolI = bitxor(symbolI,tempI);
                i = i + i; % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < kQ
                tempQ = symbolQ;
                tempQ = bitshift(tempQ,-i);
                symbolQ = bitxor(symbolQ, tempQ);
                i = i + i; % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            SymbolIndex = double(bitshift(symbolI,kQ) + symbolQ);

        else % square constellation

            symbolI = bitshift(MAP,-k/2);
            symbolQ = bitand(MAP,bitshift(M-1,-k/2));

            % while i is smaller (Number of bits per symbol)/2
            i = 1;
            while i < k/2
                tempI = symbolI;
                tempI = bitshift(tempI,-i);
                symbolI = bitxor(symbolI,tempI);

                tempQ = symbolQ;
                tempQ = bitshift(tempQ,-i);
                symbolQ = bitxor(symbolQ, tempQ);
                i = i + i; % i takes on values 1,2,4,8,...,2^n - n is an integer
            end

            SymbolIndex = double(bitshift(symbolI,k/2) + symbolQ);

        end

        MAP = SymbolIndex';
        
end
