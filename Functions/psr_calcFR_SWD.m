function FRs = psr_calcFR_SWD(spikeArray,seizures, TS)
%% psr_calcFR_SWD Calculates the firing rates during and between SWDs
%
% INPUTS:
%   spikeArray - structure output from psr_makeSpikeArray
%   seizures - structure with info about seizures
%   TS - timestamp vector (loaded from timestamps.bin; 'int32' datatype)
%
% OUTPUTS:
%   FRs - firing rates (in spks/sec). Each row is different neuron. Col1 is nonSWD FR. Col2 is FR during SWD
%
% Written by Scott Kilianski
% Updated on 2025-09-29
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
FS = 30000; % sampling frequency
recSE = double([TS(1),TS(end)])./FS; % recording start and end (in seconds)
[sstend, ctrl_stend] = psr_findsstend(seizures,recSE);

% --- Get total time during and between SWDs --- %
SWDdur = diff(sstend,1,2);  % duration of each SWD
totSWDtime = sum(SWDdur);   % total time spent in SWD
totRectime = diff(recSE);   % total time of recording
nonSWDtime = totRectime - totSWDtime; % non SWD total time

% --- Get number of spikes during and between SWDs --- %
spikeScatter = psr_findSpikes(spikeArray,sstend); % get all spikes during SWDs
spikeList = []; % initialize matrix for storing all spikes during SWD
for szi = 1:numel(spikeScatter)
    spikeList = [spikeList; spikeScatter{szi}]; % accumulate spikes for each SWD
end

% --- Compute total number of spikes during SWDs for each neuron --- %
for ni = 1:numel(spikeArray)
    spikeLog = spikeList(:,2) == ni;     % find all spikes from current neuron (ni)
    SWDspikeCount(ni,1) = sum(spikeLog); % sum them to get spike count
end

totSPKcnt = cellfun(@numel,spikeArray);  % get total spike count for each neuron 
nonSWDsc = totSPKcnt-SWDspikeCount;      % compute total number of spikes NOT during SWD
FRs(:,1) = nonSWDsc ./ nonSWDtime;       % compute nonSWD FR
FRs(:,2) = SWDspikeCount ./ totSWDtime;  % compute FR during SWDs

end % function end