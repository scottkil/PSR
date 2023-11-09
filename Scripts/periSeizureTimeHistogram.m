%%
origDir = pwd;
dataDir = 'Y:\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639';
cd(dataDir);
seizFile = dir('*curated*');
seizFile = fullfile(seizFile.folder, seizFile.name);
binSize = 0.010; % 10ms to start

%% LOAD IN SPIKES
spikeArray = psr_makeSpikeArray(dataDir);

%% LOAD IN SEIZURES
load(seizFile,'seizures');

%% FIND SEIZURE STARTS AND ENDS (1ST AND LAST TROUGH INDICES)
sstend = psr_findsstend(seizures);

%% MAKE PERI-SEIZURE TIME HISTOGRAMS
psthMat = psr_psth(spikeArray, binSize, sstend);