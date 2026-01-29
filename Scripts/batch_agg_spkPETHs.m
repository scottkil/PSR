%% === Load summed spiking activity across all SWD-PETHs === %%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

bigSP = [];
for rii = 1:size(recfin,1)
    loopClock = tic;
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    currDir = recfin.Filepath_SharkShark_{rii};
    currFile = fullfile(currDir, 'sum_spkPETH.mat');
    load(currFile,'sum_spkPETH','binCen');
    bigSP = [bigSP;sum_spkPETH];
end


%% === Separate by brain region and layer === %%
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

% === Split data into different groups based on cortical layers === %
for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    for clii = 0:6 % cortical layer
        clLog = dtbl.CorticalLayer == clii;
        totLog = clLog & stLog;
        SPP{bri,clii+1} = bigSP(totLog,:);
    end
end


%%
sumSPKs = cellfun(@(X) sum(X,1),SPP,'UniformOutput',false);
normSPKs = cellfun(@(X) X./sum(X),sumSPKs,'UniformOutput',false);

%% Plot for somatosensory and visual cortex (last 2 rows of normSPKs) %%
clList = [3,5,6,7];
colorList = [0,1,0;
    0,0,1;
    .5,0,.5;
    1,0,0];
for ii = 4:5
    figure;

    for clii = 1:numel(clList)
        clidx = clList(clii); % index
        bar(binCen,normSPKs{ii,clidx},...
            'FaceColor',colorList(clii,:),...
            'EdgeColor','none',...
            'FaceAlpha',0.5)
        hold on
    end

    if ii == 4
        title('Somatosensory');
    else
        title('Visual')
    end
end

%% Plot for somatosensory and visual cortex (last 2 rows of normSPKs) %%
clList = [3,5,6,7];
colorList = [0,1,0;
    0,0,1;
    .5,0,.5;
    1,0,0];
for ii = 4:5
    figure;

    for clii = 1:numel(clList)
        clidx = clList(clii); % index
        bar(binCen,normSPKs{ii,clidx},...
            'FaceColor',colorList(clii,:),...
            'EdgeColor','none',...
            'FaceAlpha',0.5)
        hold on
    end

    if ii == 4
        title('Somatosensory');
    else
        title('Visual')
    end
end

%% Plot in different subplots rather than on top of each other %%
clList = [3,5,6,7];
colorList = [0,1,0;
    0,0,1;
    .5,0,.5;
    1,0,0];
for ii = 4:5
    figure;

    for clii = 1:numel(clList)
        subplot(numel(clList),1,clii);
        clidx = clList(clii); % index
        bar(binCen,normSPKs{ii,clidx},...
            'FaceColor',colorList(clii,:),...
            'EdgeColor','none')
        hold on
        xline(0,'k--');
        hold off
    end

    if ii == 4
        title('Somatosensory');
    else
        title('Visual')
    end
end