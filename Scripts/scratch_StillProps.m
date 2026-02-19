recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

%%
stillProp = [];
shiftProp = [];
shiftDist = {};
percentileRank = [];
for rii = 1:size(recfin,1)
    loopClock = tic;
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    topdir = recfin.Filepath_SharkShark_{rii};
[stillProp(rii,1), shiftDist{rii}] = psr_shiftSWD_Still(topdir);
% shiftProp(rii,1) = sum(shiftDist{rii})/numel(shiftDist{rii});
percentileRank(rii,1) = mean(shiftDist{rii} <= stillProp(rii,1)) * 100;
end                  

%%
figure;
pTileVal = 95; % comparison percentile
bW = 0.015;
recNum = 22;
histogram(shiftDist{recNum},'BinWidth',bW,...
    'EdgeColor','none','FaceColor','k','Normalization','probability',...
    'FaceAlpha',0.5);
hold on
xline(stillProp(recNum),'k--','LineWidth',4);
ptv = prctile(shiftDist{recNum},pTileVal);
xline(ptv,'r','LineWidth',4);
hold off
xlabel('Proportion SWD Starting during Immobility');
ylabel('Probability');
set(gcf().Children,'FontSize',18);
% title(sprintf('Shift Distance Histogram for Recording %d', recNum));
xlim([0.6 1]);
%%
PTV = [];
for rii = 1:size(stillProp,1)
    PTV(rii,1) = prctile(shiftDist{rii},pTileVal);
end

propD = stillProp-PTV;
