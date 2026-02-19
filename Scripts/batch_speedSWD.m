%%
% clear all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

%%

for rii = 1:size(recfin,1)
    loopClock = tic;
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    topdir = recfin.Filepath_SharkShark_{rii};
    sSWD = psr_speedSWD(topdir);
    start_speed(rii,:) = mean(sSWD.start_speed,1,'omitmissing');
    end_speed(rii,:) = mean(sSWD.end_speed,1,'omitmissing');
    meanLatency(rii,1) = mean(sSWD.stopLatency);
    propStillStart(rii,1) = sum(sSWD.ss_start)/numel(sSWD.ss_start);
    propStillEnd(rii,1) = sum(sSWD.ss_end)/numel(sSWD.ss_end);
    meanSpeeds(rii,:) = [sSWD.nonSWDspeed,sSWD.SWDspeed];
end

%%
YL = [0 1.8];
cf = figure;
sax(1) = subplot(121);
psr_plotMeanSTE(sax(1),sSWD.timeAX,start_speed,'std');
hold on
xline(0,'k--','LineWidth',2);
sax(2) = subplot(122);
psr_plotMeanSTE(sax(2),sSWD.timeAX,end_speed,'std');
hold on
xline(0,'k--','LineWidth',2);
linkaxes(sax,'y');
sax(1).YLim = YL;
set(cf().Children,'FontSize',16);
sax(1).XLabel.String = ('Time from SWD Onset (s)');
sax(2).XLabel.String = ('Time from SWD End (s)');
sax(1).YLabel.String = ('Speed (cm/s)');
sax(2).YLabel.String = ('Speed (cm/s)');
sax(1).YTick = [0 0.5 1 1.5];
sax(2).YTick = [0 0.5 1 1.5];