%% Batch SWD and SWC participation rates by brain region
clear all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%%
alphaThresh = 10^-4;
for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    pLog = dtbl.MVL_pvals_FDR_adjusted <= alphaThresh; % check for significant phase-locking
    sr{bri} = dtbl.SWDPrate(stLog & pLog);
    cr{bri} = dtbl.SWCPrate(stLog & pLog);
end

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
    xlim([0 0.75])
    ylim([0 1])
    set(dFig().Children,'FontSize',24)
    hold on
    yline(mean(sr{bri}))
    hold off
        meanSR(bri,1) = mean(sr{bri});

    [h(bri,1),p(bri,1),jbstat(bri,1),critval(bri,1)] = jbtest(sr{bri}); % jarque-bera test
    [K2(bri,1), P(bri,1)] = DagosPtest(sr{bri}); % D'agostino test
end

cFig = figure;
for bri = 1:numel(ubrs)
    subplot(1,numel(ubrs),bri);
    % --- SW cycle participation CDF --- %
    CDF = histcounts(cr{bri},BinE,'Normalization','probability');
    barh(BinC,CDF,'FaceColor',clrs(bri,:),...
        'EdgeColor','none','BarWidth',1);
    xlim([0 0.2])
    ylim([0 1])
    set(cFig().Children,'FontSize',24)
        hold on
    yline(mean(cr{bri}))
    hold off
    meanCR(bri,1) = mean(cr{bri});
    [h(bri,2),p(bri,2),jbstat(bri,2),critval(bri,2)] = jbtest(cr{bri}); % Jarque-bera test
    [K2(bri,2), P(bri,2)] = DagosPtest(cr{bri}); %D'agostino test
end