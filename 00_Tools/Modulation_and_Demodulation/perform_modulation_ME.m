% This function performs digital/analog modulation on a binary
% vector/sampled analog data.
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
%   data: Input binary vector/sampled analog data.
%
% Output:
%   y: Complex baseband signal as a row vector
%
% Revisions:
% 2020-Sep-02   function was created
% 2020-Dec-21   fractional sps functionality was added

function y = perform_modulation_ME(Mod, data)

%% Convert fractional sps (i.e. sample per symbol) to integer sps
global DigitalModTypes
if mod(Mod.sps,1)~=0 && ismember(Mod.Type,DigitalModTypes)
    sps_fr = Mod.sps;
    Mod.sps = ceil(Mod.sps);
    FSPS_Flag = true;
else
    FSPS_Flag = false;
end

%% Perform Modulation
switch lower(Mod.Type)
    
    case 'msk'
        y = mskmod_ME(Mod, data);
        
    case 'gmsk'
        y = gmskmod_ME(Mod, data);        
        
    case 'fsk'
        y = fskmod_ME(Mod, data);                
        
    case 'psk'
        y = pskmod_ME(Mod, data);                        

    case 'dpsk'
        y = dpskmod_ME(Mod, data);                        

    case 'oqpsk'
        y = oqpskmod_ME(Mod, data);                        

    case 'qam'
        y = qammod_ME(Mod, data);                        

    case 'ask'
        y = askmod_ME(Mod, data);                        

    case 'am'
        y = ammod_ME(Mod, data);                        

    case 'dsb'
        y = dsbmod_ME(Mod, data);                        

    case 'lsb'
        y = lsbmod_ME(Mod, data);                        

    case 'usb'
        y = usbmod_ME(Mod, data);                        

    case 'isb'
        y = isbmod_ME(Mod, data);                        

    case 'fm'
        y = fmmod_ME(Mod, data);                        
    
    case 'pm'
        y = pmmod_ME(Mod, data);                        
end

%% Convert integer sps back to fractional sps
if FSPS_Flag
    L = length(y);
    T = (L-1)/Mod.sps+10*eps;
    t1 = (0:1/Mod.sps:T);
    t2 = (0:1/sps_fr:T);
    y = interp1(t1,y,t2,'linear');
end