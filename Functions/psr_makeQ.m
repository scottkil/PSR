function [Q, timeVec] = psr_makeQ(spikeArray,timeLims, binSize, smoothTime)
%% psr_makeQ Makes firing rate matrix for all cells across entire recording
%
% INPUTS:
%   spikeArray - cell array with each element being the spike times (in seconds) for one neuron
%   timeLims - 2-element matrix with start and end times of desired Q matrix (in seconds)
%   binSize - in seconds for binng spike trains
%   smoothTime - smoothing time window (in seconds)
%
% OUTPUTS:
%   Q - smooth firing rate matrix (in spike/s units)
%   timeVec - corresponding time (in seconds) of each column in Q
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
funClock = tic;
smoothWin = round(smoothTime/binSize);
fprintf('Making Q matrix (firing rate matrix)...\n');
binEdges = timeLims(1):binSize:timeLims(2);
timeVec = binEdges(1:end-1)+binSize/2; % time vector. Uses center of time bins
for ci = 1:numel(spikeArray)
    bstMat(ci,:) = histcounts(spikeArray{ci},binEdges); % binned spike train matrix
end
bstMat = bstMat./binSize;
Q = smoothdata(bstMat,2,'gaussian',smoothWin); % smooth firing rate vector
fprintf('Making Q matrix took %.2f seconds\n',toc(funClock));
end % function end