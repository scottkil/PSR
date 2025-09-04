%%
clear all; close all; clc
tic
cID = 0;
dataDir = 'Z:\PSR_Data\PSR_24\PSR_24_Rec2_231208_162349';
fileName = 'combined.bin';
dataType = 'int16';
numChans = 256;
wfWin = [-40 41]; % waveform sample window
winVec = wfWin(1):wfWin(2);
nWf = 2000;

spikeTimes = readNPY(fullfile(dataDir,'spike_times.npy'));
spikeClusters = readNPY(fullfile(dataDir,'spike_clusters.npy'));

spikeTimes_cc = spikeTimes(spikeClusters==cID);
spikeClusters_cc = spikeClusters(spikeClusters==cID);

filename = fullfile(dataDir,fileName);
md = psr_mapBinData(filename,numChans); % memory map data


clusterInfo = readcell(fullfile(dataDir,'cluster_info.tsv'), ...
    'FileType','text','Delimiter','\t');
chCol = find(strcmp(clusterInfo(1,:),'ch'));
cRow = find(cellfun(@(X) isequal(X,cID), clusterInfo(:,1))); % find matching row
bestChan = clusterInfo{cRow,chCol};
bestChan = bestChan + 1; % convert from 0-indexed to 1-indexed

fs = 3000;
Fc = 300; % cutoff frequency (Hz)
[b, a] = butter(2, Fc/(fs/2), 'high'); % high-pass Butterworth filter

scaleFactor = 0.195; % int16-to-uV conversion factor

baseMat = int64(repmat(winVec,nWf,1));

spikeTimes_cc = spikeTimes_cc(randperm(numel(spikeTimes_cc),nWf)); % get subsample


modMat = int64(repmat(spikeTimes_cc,1,size(baseMat,2)));
% indMat = repmat(wfWin(1):wfWin(2),numel(spikeTimes),1); % all spikes????

indMat = baseMat + modMat;
% === Index to get waveforms on best channel === %
%%
cwfd = md.Data.ch(bestChan,indMat)';
cwfd = double(reshape(cwfd,nWf,numel(winVec)))*scaleFactor;
medMat = repmat(median(cwfd,2),1,numel(winVec));
fnMat = cwfd-medMat;
ampls = min(fnMat,[],2);
toc