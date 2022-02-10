% This function performs digital/analog demodulation on a complex baseband
% signal.
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
%   Mod: Modulation structure
%       Note: For definition, see Initialize_Modulation_ME function.
%   y: Complex baseband signal as a row vector
%
% Output:
%   data: Demodulated binary/sampled analog information.
%
% Revisions:
% 2020-Sep-02   function was created
% 2020-Dec-21   fractional sps functionality was added

function [data,varargout] = perform_demodulation_ME(Mod, y)

%% Convert fractional sps (i.e. sample per symbol) to integer sps
global DigitalModTypes
if mod(Mod.sps,1)~=0 && ismember(Mod.Type,DigitalModTypes)
    
    sps_int = ceil(Mod.sps);
    
    L = length(y);
    T = (L-1)/Mod.sps+10*eps;
    t1 = (0:1/Mod.sps:T);
    t2 = (0:1/sps_int:T);
    y = interp1(t1,y,t2,'linear');
    
    Mod.sps = sps_int;
    
end

%% Perform Demodulation
switch lower(Mod.Type)
    
    case 'msk'
        data = mskdemod_ME(Mod, y);
        
    case 'gmsk'
        show_progress = true;
        data = gmskdemod_ME(Mod, y, show_progress);
        
    case 'fsk'
        data = fskdemod_ME(Mod, y);

    case 'psk'
        [data,varargout{1}] = pskdemod_ME(Mod, y);

    case 'dpsk'
        [data,varargout{1}] = dpskdemod_ME(Mod, y);

    case 'oqpsk'
        [data,varargout{1}] = oqpskdemod_ME(Mod, y);
        
    case 'qam'
        [data,varargout{1}] = qamdemod_ME(Mod, y);                        

    case 'ask'
        [data,varargout{1}] = askdemod_ME(Mod, y);                        

    case 'am'
        data = amdemod_ME(Mod, y);                        

    case 'dsb'
        data = dsbdemod_ME(Mod, y);                        

    case 'lsb'
        data = lsbdemod_ME(Mod, y);                        

    case 'usb'
        data = usbdemod_ME(Mod, y);                        

    case 'isb'
        data = isbdemod_ME(Mod, y);                        

    case 'fm'
        data = fmdemod_ME(Mod, y);                        
    
    case 'pm'
        data = pmdemod_ME(Mod, y);                        
end