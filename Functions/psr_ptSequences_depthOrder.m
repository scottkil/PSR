function [seqCell, sh, figOut, ubrs] = psr_ptSequences_depthOrder(topdir,recNum)
%% psr_ptSpikeCOMs Finds and plots center-of-mass (COM) for peri-trough spiking
%
% INPUTS:
%   topdir - top-level directory
%   recNum - recording ID number (e.g. 17.2). Used for gettting relevant per-cell information from AllCellsTable.csv
%
% OUTPUTS:
%   seqCell - cell array with following organization:
%       - Col1: Structure name
%       - Col2: number of neurons on current shank
%       - Col3: correlation of rank orders
%     *Additional note: each structure has 2 rows. Top row corresponds to shank1. Bottom is shank 2
%   sh - output from psr_ ptSpikeCOMs. Structure with shank-by-shank peri-trough data. Field ".one" and ".two" have the following subfields:
%       com: center of mass times. Col1 is for first half. Col2 is for 2nd half
%       ord: order of the c-o-m times. Col1 is for first half. Col2 is for 2nd
%       mat: peri-trough time histogram matrix with dimensions:
%         Dim1 - neurons
%         Dim2 - time
%         Dim3 - trough halves (1st and 2nd half)
%   figOut - figure handles
%   brName - brain region name
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
load('UCLA_256F.mat','ycoords');

dtbl = readtable('AllCellsTable.csv',...
    'Delimiter',',');       % read in data table

% --- Limit dtbl to only current recording --- %
dtbl = dtbl(dtbl.RecID == recNum,:);

ubrs = unique(dtbl.SimpleName);

% --- Get all spike times and trough times --- %
[spikeArray, neuronChans] = psr_makeSpikeArray(fullfile(topdir,'kilosort4/'));
chDepth = ycoords(neuronChans+1); % +1 because probe channels are 0-indexed

seizFile = fullfile(topdir,'seizures_EEG.mat'); % path to "seizures" file
TT = psr_getTroughTimes(seizFile);

% --- peri-trough PETH --- %
[ptPETH, BC] = psr_makePtNeuronPETH(spikeArray, TT, winsize,tstep);

seqCell = {}; % sequence cell to append sequence data to
for brii = 1:numel(ubrs) % brain region FOR loop

    pLog = dtbl.MVL_pvals_FDR_adjusted <= alphaThresh; % check for significant phase-locking
    brLog = strcmp(dtbl.SimpleName,ubrs{brii}); % current brain structure

    sh1log = neuronChans < 128 & pLog & brLog; % shank identity
    sh2log = neuronChans >= 128 & pLog & brLog; % shank identity - shank 2
    shLog(:,1) = sh1log;
    shLog(:,2) = sh2log;
    [depthOrder{1,1}, depthOrder{1,2}] = sort(chDepth(sh1log),'ascend');
    [depthOrder{2,1}, depthOrder{2,2}] = sort(chDepth(sh2log),'ascend');
    [sh(brii), fullCom, figOut(brii)] = psr_ptSpikeCOMs_depthOrder(ptPETH,BC,shLog,smoothwin,plotFlag,depthOrder);

    tmpCell{1,1} = recNum;
    tmpCell{1,2} = ubrs{brii}; % store brain region name

    % --- Get correlations for shank 1 --- %
    currSH = sh(brii).one;
    tmpCell(1,3:7) = dealCorr(currSH);
    seqCell = [seqCell;tmpCell]; % append temporary cells

    % --- Get correlations for shanks 2 --- %
    currSH = sh(brii).two;
    tmpCell(1,3:7) = dealCorr(currSH);
    seqCell = [seqCell;tmpCell];

    figOut(brii).Children(1).Title.String = sprintf('%.1f - %s - Shank 2',recNum, ubrs{brii});
    figOut(brii).Children(2).Title.String = sprintf('%.1f - %s - Shank 1',recNum, ubrs{brii});



end
end % function end


function dealOut = dealCorr(currSH)
% Handles correlations between half 1 and half 2 from current shank
% `dealOut` output variables has following structure:
%   dealOut{1}: number of neurons
%   dealOut{2}: pearson correlation of centers of mass from half 1 to 2
%   dealOut{3}: corresponding p value for that pearson correlation
%   dealOut{4}: spearman rank correlation
%   dealOut{5}: p value for the spearman rank correlation

dealOut{1,1}= size(currSH.com,1); % store number of neurons
% --- Store default correlation and p values. Used when there are no/1 neurons --- %
dealOut{1,2} = 0; % default Pearson correlation
dealOut{1,3} = 1; % default Pearson corr p-value
dealOut{1,4} = 0; % default Spearman correlation
dealOut{1,5} = 1; % default Spearman p-value

if dealOut{1,1} > 1
    [tmpCorr, corrP] = corrcoef(currSH.com(:,1),currSH.com(:,2),'rows','complete'); % correlation between latencies from half 1 to half 2
    dealOut{1,2} = tmpCorr(2); % store correlation (r value)
    dealOut{1,3} = corrP(2);
    [dealOut{1,4}, dealOut{1,5}] = corr(currSH.com(:,1), currSH.com(:,2), 'type', 'Spearman','rows','complete');

end

end % nested function end