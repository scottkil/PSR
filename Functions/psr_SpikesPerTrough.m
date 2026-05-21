function [spt] = psr_SpikesPerTrough(topdir,winSize)
%% psr_SpikesPerTrough Returns the number of spikes within [winSize] for each SWD trough
%
% INPUTS:
%   topdir - top-level directory with all relevant data
%   winSize  - window duration around trough to look for spiking (seconds). Default is 0.1s (100ms)
%
% OUTPUTS:
%   spt - spikes-per-trough matrix. rows = neurons. columns = SWD troughs.
%
% Written by Scott Kilianski
% Updated on 2026-04-13
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    winSize = 0.1;
end

halfWin = winSize/2;
seizFile = fullfile(topdir,'seizures_EEG.mat');
KSdir = fullfile(topdir,'kilosort4/');

TT = psr_getTroughTimes(seizFile);
SA = psr_makeSpikeArray(KSdir);

% --- Building `spk_per_TT` (logical if one spike near SWC trough) --- %
% ---   rows are units, columns are SWD troughs --- %
TTsse = [TT-halfWin,TT+halfWin];
for swcii = 1:size(TTsse,1)
    TL = [TTsse(swcii,1), TTsse(swcii,2)]; % temporary limits (current SWD start and end)
    szC = cellfun(@(X) X>=TL(1) & X<=TL(2), SA,'UniformOutput',false); % find if there are spikes within limits
    spt(:,swcii) = cellfun(@sum, szC); % logical for at least one spike
end

% spt = sum(spk_per_TT,2);

end % function end