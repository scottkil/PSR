function seizQ = psr_makeSeizQ(spikeArray, sstend, binSize, buff, smoothTime)
%% psr_makeSeizQ Generate Q matrix (binned firing rate matrix) from times within limits
%
% INPUTS:
%   spikeArray - cell array with each element being the spike times (in seconds) for one neuron
%   binSize - in seconds for binng spike trains
%   sstend - 2 row matrix with times (in seconds) 
%       1st row is seizure start times. 
%       2nd is seizure end times
%   buff - time buffer (in seconds) to grab before & after seizure start and end
%   smoothTime - smoothing time window (in seconds)
%
% OUTPUTS:
%   seizQ - Cell array storing binned spike train matrices (Q matrices) 
%               1 Q matrix for each seizure. Seizures are different length
%               so Q matrices are different # of columns
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
funClock = tic;
smoothWin = round(smoothTime/binSize);
% fprintf('Calculating peri-sezure time histograms...\n');
for szi = 1:size(sstend,1)
    binEdges = (sstend(szi,1)-buff):binSize:(sstend(szi,2)+buff);
    bstMat = [];
    for ci = 1:numel(spikeArray)
        bstv = histcounts(spikeArray{ci},binEdges); % binned spike train vector
        bstMat(ci,:) = bstv./binSize;   % convert to firing rate (spikes/s)
    end
    bstMat = smoothdata(bstMat,2,'gaussian',smoothWin); % smooth firing rate vector
    seizQ{szi,1} = bstMat;
end
% fprintf('Calculating peri-sezure time histograms took %.2f seconds\n',toc(funClock));
end % function end