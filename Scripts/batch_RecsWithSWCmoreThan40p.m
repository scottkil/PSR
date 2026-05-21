%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

%%
recLog = false(size(recfin,1),1);
br = 'Somatosensory';
SWCPrate_thresh = 0.4;
minThresh = 5; % minimum number of neurons meeting above criteria
for rii = 1:size(recfin,1)
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    currRec = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recIDs(rii) = str2num(currRec);
    subTable = dtbl(dtbl.RecID == recIDs(rii),:);
    critLog = strcmp(subTable.SimpleName,br) & subTable.SWCPrate_50msWindow>SWCPrate_thresh;
    CIDs{rii,1} = subTable.ClusterID_(critLog); % cluster IDs of the 'good' neurons (those meeting criteria)
    CLay{rii,1} = subTable.CorticalLayer(critLog); % cortical layer
    if sum(critLog) >= minThresh
        recLog(rii) = true;
    end
end

remRecs = recfin.Filepath_SharkShark_(recLog);
CIDs(~recLog) = [];
CLay(~recLog) = [];
recIDs(~recLog) = [];
%%
for rii = 1:numel(remRecs)
    KSdir = fullfile(remRecs{rii},'kilosort4/');
    [spikeArray, ~, clustIDs] = psr_makeSpikeArray(KSdir);
    keepLog = ismember(clustIDs,CIDs{rii});
    SA = spikeArray(keepLog);

    % --- Depth order by cortical layer --- %
    tmpLay = CLay{rii};
    [~,oIDX] = sort(CLay{rii},'descend');
    SA = SA(oIDX);
    % ------------------------------------- %

    % - Loop over each SWD trough
    winSize = 0.05;
    halfWin = winSize/2;
    seizFile = fullfile(remRecs{rii},'seizures_EEG.mat');


    %% --- Looping over each SWC trough --- %

    [TT, tID] = psr_getTroughTimes(seizFile);
    pfFile = sprintf('/home/scott/Documents/RasterTest_%.1f.pdf',recIDs(rii));
    TTsse = [TT-halfWin,TT+halfWin];
    rFig = figure; % raster figure
    rAX = axes;
    rscat = scatter([],[],128,'k','|','LineWidth',3);
    ttle = title('');
    set(rAX,'YLim',[0 numel(SA)+1],'XLim',[-halfWin halfWin],...
        'XLimMode','manual','YLimMode','manual');
    for swcii = 1:size(TTsse,1)
        TL = [TTsse(swcii,1), TTsse(swcii,2)]; % temporary limits (current SWD start and end)
        szC = cellfun(@(X) X>=TL(1) & X<=TL(2), SA,'UniformOutput',false); % find if there are spikes within limits
        spkTimes = [];
        spkIDs = [];
        for nii = 1:numel(SA)
            tmpTimes = SA{nii}(szC{nii}) - TT(swcii);
            spkTimes = [spkTimes; tmpTimes];
            spkIDs = [spkIDs; ones(size(tmpTimes))*nii];
        end
        set(rscat,'XData',spkTimes,'YData',spkIDs);
        set(ttle,'String',sprintf('Trough ID:  %.2f',tID(swcii)));
        drawnow;
        exportgraphics(rFig, pfFile,...
            'Append', true);
    end
    close(rFig);
end