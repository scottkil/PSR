function [Q, timeVec] = psr_makeSlidingQ(spikeArray,timeLims, binSize, tstep)
%% psr_makeSlidingQ Makes firing rate matrix for all cells across entire recording
%
% INPUTS:
%   spikeArray - cell array with each element being the spike times (in seconds) for one neuron
%   timeLims - 2-column matrix with start and end times of desired Q matrix (in seconds)
%   binSize - in seconds for binng spike trains
%   tstep - time step between bins (in seconds). Should divide binSize into whole numbers (not fractions)
%
% OUTPUTS:
%   Q - smooth firing rate matrix (in spike/s units)
%   timeVec - corresponding time (in seconds) of each column in Q
%
% Written by Scott Kilianski
% Updated on 2026-04-15
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
funClock = tic;
StepsPerBin = floor(binSize/tstep);
tstep_corrected = binSize/StepsPerBin;
binEdges = timeLims(1):binSize:timeLims(2);
binMat(1,:) = binEdges;
for tsii = 1:(StepsPerBin-1)
    binMat(tsii+1,:) = binEdges+(tsii*tstep_corrected);
end
timeMat = binMat(:,1:end-1)+(binSize/2);
fprintf('Making Q matrix (firing rate matrix) with sliding window...\n');
% timeVec = binEdges(1:end-1)+binSize/2; % time vector. Uses center of time bins
timeVec = timeMat(:);
for ci = 1:numel(spikeArray)
    for bii = 1:size(binMat,1) % for each binning series
        bstMat(ci,bii,:) = histcounts(spikeArray{ci},binMat(bii,:)); % binned spike train matrix
    end
end
Q = bstMat./binSize; % dividing binned spike train to generate firing rates (spikes/sec)
Q = reshape(Q,size(Q,1),size(Q,2)*size(Q,3));
% Q = smoothdata(bstMat,2,'gaussian',smoothWin); % smooth firing rate matrix
fprintf('Making sliding window Q matrix took %.2f seconds\n',toc(funClock));
end % function end