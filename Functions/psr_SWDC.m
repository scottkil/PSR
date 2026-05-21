function [SWDprop, SWCprop] = psr_SWDC(topdir,winSize)
%% psr_SWDC Determines what proportion of SWDs and SW cycles (SWC) given firing during
%
% INPUTS:
%   topdir - top-level directory with all relevant data
%   winSize  - window duration around trough to look for spiking (seconds). Default is 0.03s (30ms)
%
% OUTPUTS:
%   SWDprop - proportion of SWDs neuron fire during. Length(SWDprop): # neurons
%   SWCprop - proportion of SW cycles (SWC) neuron fire during. Length(SWDprop): # neurons
%
% Written by Scott Kilianski
% Updated on 2026-04-13
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    winSize = 0.03;
end

halfWin = winSize/2;
seizFile = fullfile(topdir,'seizures_EEG.mat');
KSdir = fullfile(topdir,'kilosort4/');

TT = psr_getTroughTimes(seizFile);
sstend = psr_findsstend_fromFile(topdir);

SA = psr_makeSpikeArray(KSdir);

% --- Building `spk_per_sz` (logical if one spike during SWD) --- %
% ---   rows are units, columns are SWDs --- %
for szii = 1:size(sstend,1)
    TL = [sstend(szii,1), sstend(szii,2)]; % temporary limits (current SWD start and end)
    szC = cellfun(@(X) X>=TL(1) & X<=TL(2), SA,'UniformOutput',false); % find if there are spikes within limits
    spk_per_sz(:,szii) = cellfun(@sum, szC)>0; % logical for at least one spike
end

SWDprop = sum(spk_per_sz,2)/szii;

% --- Building `spk_per_TT` (logical if one spike near SWC trough) --- %
% ---   rows are units, columns are SWCs (spike-wave cycles) --- %
TTsse = [TT-halfWin,TT+halfWin];
for swcii = 1:size(TTsse,1)
    TL = [TTsse(swcii,1), TTsse(swcii,2)]; % temporary limits (current SWD start and end)
    szC = cellfun(@(X) X>=TL(1) & X<=TL(2), SA,'UniformOutput',false); % find if there are spikes within limits
    spk_per_TT(:,swcii) = cellfun(@sum, szC)>0; % logical for at least one spike
end

SWCprop = sum(spk_per_TT,2)/swcii;

end % function end