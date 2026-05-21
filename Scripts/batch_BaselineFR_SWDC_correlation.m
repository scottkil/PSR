%% Batch SWD and SWC participation rates by brain region
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%% nonSWD firing rates vs. SWC participation rates
for bri = 1:numel(ubrs)
        stLog = strcmp(simpName,ubrs{bri});
    cr{bri} = dtbl.SWCPrate_50msWindow(stLog);
    bfr{bri} = dtbl.nonSWDFR(stLog);
    figure;
    scatter(bfr{bri},cr{bri})
        title(ubrs{bri});

end

%% Mean vector angle vs. SWC participation rate
for bri = 1:numel(ubrs)
        stLog = strcmp(simpName,ubrs{bri});
    cr{bri} = dtbl.SWCPrate_50msWindow(stLog);
    tmpa = dtbl.MeanVectorAngle_toFCXEEG_(stLog);
    tmpa(tmpa>180) = tmpa(tmpa>180)-360;
    mva{bri} = tmpa; 
    figure;
    scatter(cr{bri},mva{bri})
        title(ubrs{bri});

end

%%
dFig = figure;
dAX = axes;
cFig = figure;
cAX = axes;
BinSize = 0.05;
BinE = 0:BinSize:1;
BinC = BinE(2:end)-(BinSize/2);
clrs = psr_assignColors(ubrs);
% for bri = 1:numel(ubrs)
%     % --- SWD participation CDF --- %
%     CDF = histcounts(sr{bri},BinE,'Normalization','probability');
%     axes(dAX);
%     hold on
%     % plot(BinC,CDF,'Color',clrs(bri,:),'LineWidth',3);
%     bar(BinC,CDF,'FaceColor',clrs(bri,:));
% 
%     % --- Spike wave cycle participation CDF --- %
%     CDF = histcounts(cr{bri},BinE,'Normalization','probability');
%     axes(cAX);
%     hold on
%     % plot(BinC,CDF,'Color',clrs(bri,:),'LineWidth',3);
%     bar(BinC,CDF,'FaceColor',clrs(bri,:));
% end

dFig = figure;
for bri = 1:numel(ubrs)
    subplot(1,numel(ubrs),bri);
    % --- SWD participation CDF --- %
    CDF = histcounts(sr{bri},BinE,'Normalization','probability');
    barh(BinC,CDF,'FaceColor',clrs(bri,:),...
        'EdgeColor','none','BarWidth',1);
        xlim([0 0.55])
    ylim([0 1])
    set(dFig().Children,'FontSize',24)
end

cFig = figure;
for bri = 1:numel(ubrs)
    subplot(1,numel(ubrs),bri);
    % --- SW cycle participation CDF --- %
    CDF = histcounts(cr{bri},BinE,'Normalization','probability');
    barh(BinC,CDF,'FaceColor',clrs(bri,:),...
        'EdgeColor','none','BarWidth',1);
    xlim([0 0.32])
    ylim([0 1])
        set(cFig().Children,'FontSize',24)
end