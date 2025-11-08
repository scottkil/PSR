%% === Plot all the cumulative distribution of proportion-of-population vectors together === %%
bhse = bigHSE; % output from batch_HSE script
nnThresh = 10; % only keep entries with >= this number of neurons

% --- Apply number of neruons threhsold --- %
keepLog = [bhse.nn]>=nnThresh;
bhse = bhse(keepLog); % Filter bhse based on the neuron threshold
% --- Structures to look at --- %
structList = {'Somatosensory',...
    'Visual',...
    'Frontal',...
    'Hipp',...
    'Caudoputamen'};
% structList = {'Somatosensory','Visual'};
% ----------------------------- %

indFig = figure;
meanFig = figure;
xvec = bhse(1).distX; % x vector for distributions (identical for all recordings)
numStruct = numel(structList);
for ii = 1:numStruct
    cstr = structList{ii};
    cIDX = find(strcmp({bhse.name}',cstr));
    blArr = [];
    swdArr = [];
    for rii = 1:length(cIDX)
        ridx = cIDX(rii); % get current index
        cbl = bhse(ridx).basecdf; % current array for current structure on this iteration
        cswd = bhse(ridx).SWDcdf;
        blArr = [blArr;cbl];
        swdArr = [swdArr; cswd];
    end

    % --- Individual CDFs --- %
    figure(indFig);
    subplot(1,numStruct,ii);
    hold on
    h = plot(xvec,blArr,'k', 'LineWidth', 2);
    for hii = 1:numel(h)
        h(hii).Color(4) = 0.5; % Set alpha to 0.5 (semitransparent)
    end
    h = plot(xvec,swdArr,'r', 'LineWidth', 2);
    for hii = 1:numel(h)
        h(hii).Color(4) = 0.5; % Set alpha to 0.5 (semitransparent)
    end    
    hold off
    title(cstr);
    % ----------------------- %

    % --- Mean CDFs --- %
    figure(meanFig);
    subplot(1,numStruct,ii);
    meanBl = mean(blArr, 1);
    meanSwd = mean(swdArr, 1);
    plot(xvec, meanBl, 'k', 'LineWidth', 3);
    hold on
    plot(xvec, meanSwd, 'r', 'LineWidth', 3);
    title(cstr);
    % ----------------- %
end
set(indFig().Children,'YLim',[0 1]); % for some reason doesn't auto set to this