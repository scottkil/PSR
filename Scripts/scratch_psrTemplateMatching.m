
seizFile = fullfile(topdir,'seizures_EEG.mat');
load(seizFile,"seizures");
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),...
    'Delimiter',',');
inhibLog = logical(dtbl.Inhibitory);

FS = 30000;

winSize = 0.05;
halfWin = winSize/2;
binWidth = winSize; % seconds

KSdir = fullfile(topdir,'kilosort4/');
[spikeArray , clustIDs] = psr_makeSpikeArray(KSdir);
tLims(1) = 0;
tLims(2) = max(cellfun(@max,spikeArray));
tstep = 0.005;
[Q, timevec] = psr_makeSlidingQ(spikeArray,tLims,binWidth,tstep);

[TT, tID] = psr_getTroughTimes(seizFile);

ad = psr_binLoadData(fullfile(topdir,'analogData.bin'),1,3000);

%%
k = 0; % indexing variable
for ttii = 1:2:numel(TT)
    k = k+1;
    [~, mindx] = min(abs(TT(ttii)-timevec)); % find closest time in the time vector corresponding to Q matrix
    aggPV(:,k) = Q(:,mindx); % store that population vector
end
templatePV = mean(aggPV,2); % this mean activity is the template

tmpMatch = Q'*templatePV;   %

%%
sax(1) = subplot(211);
plot(ad.time,ad.data,'k');

sax(2) = subplot(212);
plot(timevec,tmpMatch);
linkaxes(sax,'x');

% Is this template match any better than chance?