%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

winSize = 0.2;
winStep = 0.001;
halfWin = winSize/2;
winE = -halfWin:winStep:halfWin;
CE = winE(1:end-1)+(winStep/2); % histogram bin centers
%%
bigProb = []; % probabilities
bigFL = []; %mean first and L spikes
rspkt = {};
for rii = 1:size(recfin,1)
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    currRec = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    topdir = recfin.Filepath_SharkShark_{rii};
    ptspk = psr_ptSpikeTimesAndProbs(topdir,winSize,winStep);
    mFLspk = [mean(ptspk.spkF,2,'omitmissing'), mean(ptspk.spkL,2,'omitmissing')];
    bigFL = [bigFL;mFLspk]; % append mean first and last spike times
    bigProb = [bigProb; ptspk.spkProb]; % append spike probabilities matrices
    rspkt = [rspkt;ptspk.rSpikeTimes]; % append total relative peri-trough spike times
end

%%
spkDensity = cellfun(@(X) histcounts(X,winE),rspkt,...
    'UniformOutput',false);
spkDensity = cell2mat(spkDensity);
% figure; plot(CE,mean(spkDensity,1,'omitmissing'));
simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    % inhibLog = dtbl.Inhibitory & stLog;
    % excitLog = ~dtbl.Inhibitory & stLog;
    mFL(bri,:) = mean(bigFL(stLog,:),1,'omitmissing');
    mProb(bri,:) = mean(bigProb(stLog,:),1,'omitmissing');
end

%%
figure;
plot(CE,mProb,'LineWidth',2.5);
legend(ubrs);

%%
CL = [2,4,5,6];
s1Log = strcmp(simpName,'Somatosensory');
for clii = 1:numel(CL)
    clLog = dtbl.CorticalLayer==CL(clii);
    finLog = s1Log & clLog;
    Lfl(clii,:) = mean(bigFL(finLog,:),1,'omitmissing');
    Lprob(clii,:) = mean(bigProb(finLog,:),1,'omitmissing');
    bp{clii} = bigProb(finLog,:);
    baseProb(clii,1) = mean(dtbl.nonSWDFR(finLog)*winStep);   % average baseline probability of firing
end

%%
repBase = repmat(baseProb,1,size(Lprob,2));
modProb = Lprob-repBase;
figure;
% plot(CE,Lprob,'LineWidth',2.5);
plot(CE,modProb,'LineWidth',2.5);
legend;
hold on
yline(0,'k--')

%% PLotting means +- std/ste
figure
sax = axes;
psr_plotMeanSTE(sax,CE,bp{4},'ste');