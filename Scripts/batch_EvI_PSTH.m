%%
clear all; close all; clc

recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
twin = 0.1;
dt = 0.01;
buff = 3;
minNPC = 5; % minimum neurons per class

%%
startU = [];
startI = [];
endU = [];
endI = [];
startRatio = [];
endRatio = [];

for rii = 1:size(recfin,1)
    topdir = recfin.Filepath_SharkShark_{rii};
    ctFile = sprintf('%sCellInfo.csv',topdir);
    CI = readtable(ctFile,...
        'Delimiter',',');       % read in recording info data

    sLog = (strcmp(CI.SimpleName,'Somatosensory'));
    subTable = CI(sLog,:);

    % Look for more than minNPC neurons per class (inhibitory vs. other)
    if sum(~subTable.Inhibitory) >= minNPC && sum(subTable.Inhibitory) >= minNPC
        fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
            recfin.Subject_(rii),recfin.Recording_(rii));
        [psth, timevec] = psr_eiPSTH(topdir, twin, dt,buff);
        [psthRatio, timevec] = psr_eiRatioPSTH(topdir, twin, dt,buff);
    else
        continue
    end

    brK = find(strcmp({psth.name},'Somatosensory')); % brain region index

    startU = [startU; psth(brK).aa(1,:)]; % append unclassified START PSTH
    startI = [startI; psth(brK).aa(2,:)];     % append inhibitory START PSTH
    endU = [endU; psth(brK).bb(1,:)];         % append unclassified END PSTH
    endI = [endI; psth(brK).bb(2,:)];         % append inhibitory END PSTH

    startRatio = [startRatio;psthRatio(brK).aa];
    endRatio = [endRatio; psthRatio(brK).bb];
end

%% Loop through each psth and get
figure;
sax(1) = subplot(121);
sax(2) = subplot(122);
psr_plotMeanSTE(sax(1),timevec,startU,'std');
title("unclassified")
psr_plotMeanSTE(sax(2),timevec,endU,'std');
drawnow
set(gcf().Children,'XTick',[-buff:buff],...
    'YTick',[-2 -1 0 1 2],...
    'YLim',[-2 2.2], 'XLim',[-buff buff],...
    'FontSize',24)

figure;
sax(3) = subplot(121);
sax(4) = subplot(122);
psr_plotMeanSTE(sax(3),timevec,startI,'std');
title('Inhibitory');
psr_plotMeanSTE(sax(4),timevec,endI,'std');

drawnow
set(gcf().Children,'XTick',[-buff:buff],...
    'YTick',[-2 -1 0 1 2],...
    'YLim',[-2 2.2], 'XLim',[-buff buff],...
    'FontSize',24)

figure;
sax(5) = subplot(121);
sax(6) = subplot(122);
psr_plotMeanSTE(sax(5),timevec,startRatio,'std');
psr_plotMeanSTE(sax(6),timevec,endRatio,'std');
drawnow
set(gcf().Children,'XTick',[-buff:buff],'XLim',[-buff buff],...
        'YTick',[-2 -1 0 1 2],'YLim',[-2 2.2],...
    'FontSize',24)


%%
% figure;
% sax(1) = subplot(121);
% % sax(2) = subplot(222);
% plot(sax(1),timevec,mean(startU,1),'b');
% 
% hold on
% plot(timevec,mean(startI,1),'r');
% 
% sax(2) = subplot(122);
% % sax(2) = subplot(222);
% plot(sax(2),timevec,mean(endU,1),'b');
% hold on
% plot(timevec,mean(endI,1),'r');
% 
% linkaxes(sax,'y');
% set(sax(1),'YLim',[-1.5 1.2]);
