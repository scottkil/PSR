function seqCell = psr_ptSequences(topdir,recNum)
%% psr_ptSpikeCOMs Finds and plots center-of-mass (COM) for peri-trough spiking
%
% INPUTS:
%   ptPETH - peri-trough time histogram for neuron spiking with following dimensions:
%      Dim1 - neurons
%      Dim2 - times (relative to trough) (in seconds). Same length as `BC`
%      Dim3 - troughs. Individual SWD troughs of recording
%   BC - bin centers (in seconds). Same length as Dim2 of `ptPETH`
%   shLog - shank logical vector. shLog(:,1) has TRUEs for neurons on shank 1. shLog(:,2) has TRUEs for neurons on shank 2
%   smoothwin - smoothing window (in samples). Always operates across columns (i.e. Dim2 of ptPETH). Default is 10
%   plotFlag - 1 for plotting. 0 for none. Default is 1
%
% OUTPUTS:
%   seqCell - cell array with following organization:
%       - Col1: Structure name
%       - Col2: number of neurons on current shank
%       - Col3: correlation of rank orders
%
% Written by Scott Kilianski
% Updated on 2026-05-08
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% --- Set user-defined variables --- %
winsize = 0.101; % in seconds
tstep = 0.001; % in seconds
smoothWindow = .01; % in seconds
smoothwin = round(smoothWindow/tstep); % converting to samples
plotFlag = 1;
alphaThresh = 10^-4;

dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');       % read in data table

% --- Limit dtbl to only current recording --- %
dtbl = dtbl(dtbl.RecID == recNum,:);

simpName = dtbl.SimpleName; % get the structure names
ubrs = unique(dtbl.SimpleName);

% --- Get all spike times and trough times --- %
[spikeArray, neuronChans] = psr_makeSpikeArray(fullfile(topdir,'kilosort4/'));
seizFile = fullfile(topdir,'seizures_EEG.mat'); % path to "seizures" file
TT = psr_getTroughTimes(seizFile);

% --- peri-trough PETH --- %
[ptPETH, BC] = psr_makePtNeuronPETH(spikeArray, TT, winsize,tstep);

% --- Half and half split --- %
ttLog1 = (1:numel(TT)) < (numel(TT)/2); % logical to first half of all troughs

seqCell = {}; % sequence cell to append sequence data to
for brii = 1:numel(ubrs) % brain region FOR loop

    pLog = dtbl.MVL_pvals_FDR_adjusted <= alphaThresh; % check for significant phase-locking
    brLog = strcmp(dtbl.SimpleName,ubrs{brii}); % current brain structure

    shLog(:,1) = neuronChans < 128 & pLog & brLog; % get shank identities. Shank 1 or 2
    shLog(:,2) = neuronChans >= 128 & pLog & brLog; % get shank identities. Shank 1 or 2

    [sh(brii), fullCom, figOut] = psr_ptSpikeCOMs(ptPETH,BC,shLog,smoothwin,plotFlag);
    
    tmpCell{1,1} = ubrs{brii}; % store brain region name

    % --- Get correlations for shank 1 --- %
    tmpCell{1,2}= size(sh(brii).one.com,1); % store number of neurons
    tmpCorr = corrcoef(sh(brii).one.ord(:,1),sh(brii).one.ord(:,2)); % correlation between rank orders from 1st and 2nd half - shank 1
    tmpCell{1,3} = tmpCorr(2); % store correlation (r value)
    seqCell = [seqCell;tmpCell]; % append temporary cells

    % --- Get correlations for shanks 2 --- %
    tmpCell{1,2} = size(sh(brii).two.com,1);
    tmpCorr = corrcoef(sh(brii).two.ord(:,1),sh(brii).two.ord(:,2)); % correlation between rank orders from 1st and 2nd half - shank 1
    tmpCell{1,3} = tmpCorr(2);
    seqCell = [seqCell;tmpCell];

    %%
    if 0
        % --- First and 2nd half split --- %
        for hii = 1:2
            if hii == 1
                currLog = ttLog1; % first half of troughs
            else
                currLog = ~ttLog1; % second half of troughs
            end

            % --- Average over troughs --- %
            meanptp = mean(ptPETH(:,:,currLog),3,'omitmissing');
            normMat = psr_makePlotMatrix(meanptp,10);

            % --- Find center-of-mass indices --- %
            idx = 1:size(ptPETH,2);
            for ni = 1:numel(spikeArray)
                comV(ni,hii) = sum(idx .* normMat(ni,:)) / sum(normMat(ni,:)); % center-of-mass
            end

            % --- Separate units by shank --- %
            sh1Mat(:,:,hii) = normMat(sh1Log,:);
            sh2Mat(:,:,hii) = normMat(~sh1Log,:);
        end
        comT = (comV-midIdx)*tstep; % converting center-of-mass values to trough-relative times

        % --- Sort units by their center-of-mass order --- %
        halfLead = 1; % pick which half of trough times to use for plotting (1 or 2)
        if halfLead == 1
            halfFollow = 2;
        else
            halfFollow = 1;
        end
        for hii = 1:2
            [comv1(:,hii), ord1(:,hii)] = sort(comT(sh1Log,hii),'ascend');
            [comv2(:,hii), ord2(:,hii)] = sort(comT(~sh1Log,hii),'ascend');
        end

        % Plotting action
        midIdx = size(sh1Mat,2)/2; % middle index

        figure;
        subplot(121);
        yd = 1:size(sh1Mat,1);
        Cord = ord1(:,halfLead);
        imagesc(BC,yd,sh1Mat(Cord,:,halfLead));
        hold on
        xlv = (comv1(:,halfLead)-midIdx)*tstep; % x-line values
        plot(xlv,yd,'r','LineWidth',2);
        xlv2 = (comv1(:,halfFollow)-midIdx)*tstep; % x-scatter values
        scatter(xlv2,yd,'g','filled','o');
        
        xlv

        subplot(122);
        yd = 1:size(sh2Mat,1);
        Cord = ord2(:,halfLead);
        plotMat = sh2Mat(Cord,:,halfLead);
        imagesc(BC,yd,plotMat);
        hold on
        xlv = (comv2(:,halfLead)-midIdx)*tstep; % x-line values
        plot(xlv,yd,'r');
        xlv2 = (comv2(:,halfFollow)-midIdx)*tstep; % x-scatter values
        scatter(xlv2,yd,'g','filled','o');
        colormap(flipud(bone));
        title(ubrs{brii})
    end
end