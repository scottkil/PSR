function spikeScatter = psr_findSpikes(spikeArray,timeLims)
%% psr_findSpikes Returns spikes and unit #s within specific time limits
%
% INPUTS:
%   spikeScatter - cell array 
%   timeLims - col1 is beginning and col2 is end of time limits (seconds)
%
%
% OUTPUTS:
%   spikeScatter - cell array where each cell is nx2 matrix.
%                   Each row is spike. Col1 is spike times (seconds). Col2 is unit #
%
% Written by Scott Kilianski
% Updated on 2025-09-29
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
for szi=1:size(timeLims,1)
    spikeTimes = []; % temporarily stores spike times and unit #
    spikeUnits = [];
    for ci = 1:size(spikeArray,1)
        keepLog = spikeArray{ci}>timeLims(szi,1) & spikeArray{ci} < timeLims(szi,2);
        spikeTimes = [spikeTimes; spikeArray{ci}(keepLog)];
        unitVec = ones(sum(keepLog),1)*ci;
        spikeUnits = [spikeUnits; unitVec];
    end
    spikeScatter{szi,1} = [spikeTimes,spikeUnits];
end
end % function end