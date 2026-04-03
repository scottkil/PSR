function [normSP, normEP, timeArray] = psr_normPSTH(topdir, binSize, buff, smoothTime)
%% psr_normPSTH Calculates the PSTH around start and end of SWDs per structure 
%
% INPUTS:
%   topdir - path to top-level directory
%   binSize - bin width (in seconds) to count spikes (default: 0.5 seconds)
%   buff - time buffer before and after SWD (in seconds) (default: +-5 seconds)
%   smoothTime - smoothing window duration (default: binSize [which means no smoothing])
%
% OUTPUTS:
%   normSP - normalized peri-SWD START histogram
%   normEP - normalized peri-SWD END histogram
%   timeArray - corresponding time vector
%
% Written by Scott Kilianski
% Updated on 2026-03-04
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    binSize = 0.5; % seconds
    buff = 5; % seconds
    smoothTime = binSize;
elseif nargin < 3
    buff = 5; % seconds
    smoothTime = binSize;
elseif nargin < 4
    smooTime = binSize;
end

%%
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),'Delimiter',',');
simpName = dtbl.SimpleName; % get the structure names
ubrs = unique(simpName);

%%
    spikeArray = psr_makeSpikeArray(fullfile(topdir,'/kilosort4/'));

    seizFile = fullfile(topdir,'seizures_EEG.mat');       % filepath to seizure data
    load(seizFile,'seizures');    % load in seizure data
    keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % find type 1s and 2s
    seizures(~keepLog) = []; % remove bad "seizures"

    % -- FIND SEIZURE STARTS AND ENDS (1ST AND LAST TROUGH INDICES)  -- %
    for szi = 1:numel(seizures)
        sstend(szi,:) = seizures(szi).time(seizures(szi).trTimeInds([1,end])); % first and last troughs (negative peaks)
    end

    % -- MAKE Q matrices (binned spike train matrices) for each seizure  -- %
    seizQ = psr_makeSeizQ(spikeArray, sstend, binSize, buff, smoothTime);

    % -- MAKE PERI-SEIZURE TIME HISTOGRAMS  -- %
    [startPSTH, endPSTH, timeArray] = psr_makePSTH(seizQ,binSize,buff);
    meanSP = mean(startPSTH,3,'omitmissing'); % mean start PSTH for each neuron
    meanEP = mean(endPSTH,3,'omitmissing'); % mean end PSTH for each neuron
    maxVals = max([meanSP,meanEP],[],2);
    maxMat = repmat(maxVals,1,length(timeArray));
    normSP = meanSP./maxMat;
    normEP = meanEP./maxMat;
end % function end