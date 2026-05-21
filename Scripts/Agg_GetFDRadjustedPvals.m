%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names
uqrid = unique(dtbl.RecID); % find the

ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%%
alphaThresh = 10^-4;
for rii = 1:numel(ubrs)
    cLog = strcmp(dtbl.SimpleName,ubrs{rii}); % find all neurons in the current recording
    bigFDR{rii,1} = dtbl.MVL_pvals_FDR_adjusted(cLog);
    percSig(rii,1) = sum(bigFDR{rii}<=alphaThresh) / numel(bigFDR{rii}) * 100; % percentages neurons significantly phase-locked
end

%%
colorList = psr_assignColors(ubrs);
nbins = 1000;
binE = linspace(0,1,nbins+1);
binC = binE(2:end)-(binE(2)/2);
for rii = 1:numel(ubrs)
    cf = figure;
    % chc = histogram(bigFDR{rii},binE,'Normalization','cumcount');
    % set(chc,'EdgeColor','none','Facecolor',colorList(rii,:));
    plot(sort(bigFDR{rii},'ascend'),'Color',colorList(rii,:),'LineWidth',5);
    xlim([0 numel(bigFDR{rii})]);
    % ylim([0 numel(bigFDR{rii})])
    set(gca,'FontSize',24);
    xlabel('Ranked ordered neurons')
    ylabel('Adjusted p-value')
    title(ubrs{rii});
    yscale('log')
    hold on
    yline(1e-4,'k','LineWidth',2.5);
    % yticks([1e-5 1e-4 1e-3 1e-2 1e-1 1]);
    drawnow;
    fname = sprintf('//media//scottX//Figures//PSR_Figures//pvalsDist_%s.svg',ubrs{rii});
    exportgraphics(cf,fname);
end