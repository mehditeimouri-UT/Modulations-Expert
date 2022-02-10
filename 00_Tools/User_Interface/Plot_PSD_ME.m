% This function calculates and plots power spectral density of an input signal.
%   Note: The parameters for estimating PSD is prompmted y the function.
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
%   r: Input signal (a matrix with multiple channels; each row is a channel)
%   Fs: Sampling frequency of r
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%
% Revisions:
% 2020-Sep-13   function was created

function ErrorMsg = Plot_PSD_ME(r,Fs)

%% Get Parameters
Nfft = 1024;
Nfft = min(Nfft,size(r,2));
D = floor(Nfft/2);
[success,Nfft,D] = PromptforParameters_ME({sprintf('Number of FFT Points (between 64 and %d)',size(r,2)),sprintf('Segments Overlap (<Nfft)')},{num2str(Nfft),num2str(D)},'Parameters for Estimating Power Spectral Density');
if ~success
    ErrorMsg = 'Parameters for Estimating Power Spectral Density were not provided.';
    return;
end

%% Check: Nfft is positive integer scalar  and 64<=Nfft<=size(r,2)
ErrorMsg = Check_Variable_Value_ME(Nfft,'Number of FFT Points','type','scalar','class','real',...
    'class','integer','min',64,'max',size(r,2));
if ~isempty(ErrorMsg)
    return;
end

%% Check: D is positive integer scalar and 0<D<Nfft
ErrorMsg = Check_Variable_Value_ME(D,'Number of FFT Points','type','scalar','class','real',...
    'class','integer','min',1,'max',Nfft-1);
if ~isempty(ErrorMsg)
    return;
end

%% Estimating and Plotting PSD
h = figure;
set(h,'Name','PSD','NumberTitle','off'); 
for j=1:size(r,1)
    
    if size(r,1)>1
        subplot(size(r,1),1,j);
    end
    
    [p,f,~] = PSD_ME(r(1,:),Fs,Nfft,D);
    plot(f,10*log10(p));
    xlabel('Frequency (Hz)');
    ylabel('Power (dB/Hz)')
    
    if size(r,1)>1
        title(sprintf('Channel %d',j))
    end
    
    grid
    
end