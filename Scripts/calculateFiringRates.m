%%
clear all; clc

%%
% dirList{1} = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
% dirList{2} = 'Y:\PSR_Data\PSR_17\PSR_17_Rec2_231012_124907';
% dirList{3} = 'Y:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805';
% dirList{4} = 'Y:\PSR_Data\PSR_25\PSR_25_Rec2_First35min';

dirList{1} ='Y:\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634';
dirList{2} ='Y:\PSR_Data\PSR_18\PSR_18_Rec2_231016_190216';
dirList{3} ='Y:\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639';
dirList{4} ='Y:\PSR_Data\PSR_22_Day1\PSR_22_Rec2_231215_113847';
dirList{5} ='Y:\PSR_Data\PSR_23\PSR_23_Rec2_231213_153523';
dirList{6} ='Y:\PSR_Data\PSR_24\PSR_24_Rec2_231208_162349';

%%
binSize = 0.05; % in seconds
smoothTime = 0.05; % smoothing window, in seconds
FS = 30000; % sampling rate
swdFR = []; baseFR = [];
for di = 1:numel(dirList)
    dataDir = dirList{di};
    cd(dataDir);
    TSfile = dir('timestamps.bin');
    TSfile = fullfile(TSfile.folder, TSfile.name);
    TS = memmapfile(TSfile,'Format','int32'); % memory map to load TS data
    timeLims = double([TS.Data(1), TS.Data(end)]) ./ FS; % get first and last sample time (and convert to seconds)

    %% LOAD IN SPIKES
    spikeArray = psr_makeSpikeArray(dataDir);

    %% Make Q matrices
    [Q, timeVec] = psr_makeQ(spikeArray,timeLims, binSize, smoothTime);

    %% Find seizure bins and non-seizure bins
    seizFile = dir('*curated*');
    seizFile = fullfile(seizFile.folder, seizFile.name);
    load(seizFile,'seizures');
    sstend = psr_findsstend(seizures);
    seizBinLog = psr_findSeizBins(timeVec,sstend);
    swdFR = [swdFR; mean(Q(:,seizBinLog),2)];
    baseFR = [baseFR; mean(Q(:,~seizBinLog),2)];
end