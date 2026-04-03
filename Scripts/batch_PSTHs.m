%%
clear all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');       % read in data table
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names
ubrs = unique(simpName);

binSize = 0.25; % seconds
smoothTime = binSize;

% binSize = 0.01; % seconds
% smoothTime = .1; % seconds

buff = 3; % seconds
plotFlag = 0; % no plotting


%% === SAVE OUTPUTS IN TABLE OR STRUCTURE? ==== %
% --- GET STRUCTURE MEANS --- %
bigSP = [];
bigEP = [];
for rii = 1:size(recfin,1)
    recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    topdir = recfin.Filepath_SharkShark_{rii};
    [normSP, normEP, timeArray] = psr_normPSTH(topdir, binSize, buff, smoothTime);
    bigSP = [bigSP; normSP];
    bigEP = [bigEP; normEP];
    % [mean_SP, mean_EP, nn, BRs] = psr_MeanPSTHperStructure(topdir, normSP, normEP, timeArray, plotFlag);
end


%%
FSZ = 16; % font size
XL = [timeArray(1) timeArray(end)]; %x limits
% YL = [0 0.8]; % y limits
% bfName = '/media/scottX/Figures/PSR_Figures/PeriSWD_PSTH/stdev'; %base file name

YL = [0 1]; % y limits
bfName = '/media/scottX/Figures/PSR_Figures/PeriSWD_PSTH/LargeBins'; %base file name (large bins)

for uii = 1:numel(ubrs)
    cLog = strcmp(simpName,ubrs{uii});
    subSP = bigSP(cLog,:);
    subEP = bigEP(cLog,:);
    cf = figure;
    sax = axes;
    psr_plotMeanSTE(sax,timeArray,subSP,'std');
    title(sprintf('%s - SWD Start',ubrs{uii}));
    ylabel('Normalized Firing Rate')
    xlabel('Time from SWD Start (seconds)');
    set(sax,'YLim',YL,'XLim',XL,'FontSize',FSZ);
    hold on
    xline(0,'r--','LineWidth',2.5);
    hold off
    drawnow;
    exportgraphics(cf,sprintf('%s%d_start.pdf',bfName,uii));

    cf = figure;
    sax = axes;
    psr_plotMeanSTE(sax,timeArray,subEP,'std');
    title(sprintf('%s - SWD End',ubrs{uii}));
    xlabel('Time from SWD End (seconds)');
    ylabel('Normalized Firing Rate')
    set(sax,'YLim',YL,'XLim',XL,'FontSize',FSZ);
    hold on
    xline(0,'r--','LineWidth',2.5);
    hold off
    drawnow;
    exportgraphics(cf,sprintf('%s%d_end.pdf',bfName,uii));

end