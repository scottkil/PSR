%% === Plot all the cumulative distribution of proportion-of-population vectors together === %%
nnThresh = 10; % only keep entries with >= this number of neurons

% --- Structures to look at --- %
structList = {'Somatosensory',...
    'Visual',...
    'Frontal',...
    'Hippocampus',...
    'Caudoputamen'};
% structList = {'Somatosensory','Visual'};
indFig = figure;
meanFig = figure;
xvec = bigHSE(1).distX; % x vector for distributions (identical for all recordings)
for ii = 1:numel(structList)
    cstr = structList{ii};
    cIDX = find(strcmp({bigHSE.name}',cstr));
    blArr = [];
    swdArr = [];
    for rii = 1:length(cIDX)
        ridx = cIDX(rii); % get current index
        cbl = bigHSE(ridx).basecdf; % current array for current structure on this iteration
        cswd = bigHSE(ridx).SWDcdf;
        blArr = [blArr;cbl];
        swdArr = [swdArr; cswd];
    end
    
    figure(indFig);
    subplot(1,2,ii);
    hold on
    plot(xvec,blArr,'k');
    plot(xvec,swdArr,'r');
    hold off
    title(cstr);

    figure(meanFig);
    subplot(1,2,ii);
    meanBl = mean(blArr, 1);
    meanSwd = mean(swdArr, 1);
    plot(xvec, meanBl, 'k', 'LineWidth', 3);
    hold on
    plot(xvec, meanSwd, 'r', 'LineWidth', 3);
    title(['Mean ' cstr ' Distribution']);
end