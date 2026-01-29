%%
clear all; clc
%%
binSize = 0.5;    % 50ms
buff = 5;           % time buffer for making peri-seizure histograms
smoothTime = binSize;     % smoothing window duration (seconds) [set to = binSize for no smoothing]
origDir = pwd;

% dirList{1} = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
% dirList{2} = 'Y:\PSR_Data\PSR_17\PSR_17_Rec2_231012_124907';
% dirList{3} = 'Y:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805';
dirList{1} = 'Y:\PSR_Data\PSR_25\PSR_25_Rec2_First35min';
%
% dirList{1} ='Y:\robbieX\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634';
% dirList{2} ='Y:\robbieX\PSR_Data\PSR_18\PSR_18_Rec2_231016_190216';
% dirList{3} ='Y:\robbieX\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639';

nm_start =[]; nm_end = [];

%%
for dd = 1
    dataDir = dirList{dd};
    cd(dataDir);
    seizFile = dir('*curated*');
    seizFile = fullfile(seizFile.folder, seizFile.name);

    % -- LOAD IN SPIKES  -- %
    spikeArray = psr_makeSpikeArray(dataDir);

    % -- LOAD IN SEIZURES  -- %
    load(seizFile,'seizures');

    % -- FIND SEIZURE STARTS AND ENDS (1ST AND LAST TROUGH INDICES)  -- %
    sstend = psr_findsstend(seizures);

    % -- MAKE Q matrices (binned spike train matrices) for each seizure  -- %
    seizQ = psr_makeSeizQ(spikeArray, sstend, binSize, buff, smoothTime);

    % -- MAKE PERI-SEIZURE TIME HISTOGRAMS  -- %
    [startPSTH, endPSTH, timeArray] = psr_makePSTH(seizQ,binSize,buff);

    % -- Get normalized population average -- %
    nm_start = [nm_start; psr_psthMat2NormMean(startPSTH)];
    nm_end = [nm_end; psr_psthMat2NormMean(endPSTH)];

end

%% Figures!
figure;
lax = subplot(121);
psr_plotMeanSTE(lax,...,
    timeArray, nm_start, 'ste');
% psr_plotMeanSTE(lax,...,
%     timeArray, mean(startPSTH,3), 'ste'); %nor-normalized firing rates
title('Start of seizure');
rax = subplot(122);
psr_plotMeanSTE(rax,...,
    timeArray, nm_end, 'ste');
% psr_plotMeanSTE(rax,...,
%     timeArray, mean(endPSTH,3), 'ste'); % non-normalized firing rates
title('End of seizure')
cd(origDir);
% seizFR = ;