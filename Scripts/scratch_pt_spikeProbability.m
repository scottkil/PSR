topdir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day2/PSR_40_Day2_Rec1_250215_173210/';

winSize = 0.2;
winStep = 0.001;
halfWin = winSize/2;
winE = -halfWin:winStep:halfWin;
CE = winE(1:end-1)+(winStep/2); % histogram bin centers

ptspk = psr_ptSpikeTimesAndProbs(topdir,winSize,winStep);
mFLspk = [mean(ptspk.spkF,2,'omitmissing'), mean(ptspk.spkL,2,'omitmissing')];
% bigProb = mean(ptspk)
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),...
    'Delimiter',',');

%%
spkDensity = cellfun(@(X) histcounts(X,winE),ptspk.rSpikeTimes,...
    'UniformOutput',false);
spkDensity = cell2mat(spkDensity);

simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    % inhibLog = dtbl.Inhibitory & stLog;
    % excitLog = ~dtbl.Inhibitory & stLog;
    mFL(bri,:) = mean(mFLspk(stLog,:),1,'omitmissing');
    mProb(bri,:) = mean(ptspk.spkProb(stLog,:),1,'omitmissing');
    spkDen(bri,:) = sum(spkDensity(stLog,:),1,'omitmissing');
end

%%
figure; 
plot(CE,spkDen(2,:));

figure; 
plot(CE,mProb(2,:));

