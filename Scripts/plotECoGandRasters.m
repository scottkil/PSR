%%
clear all; close all; clc;
%%
origDir = pwd;
buff = 2;           % time buffer for displaying peri-seizure data

% dirList{1} = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
% dirList{1} = 'Y:\PSR_Data\PSR_17\PSR_17_Rec2_231012_124907';
% dirList{1} = 'Y:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805';
% dirList{1} = 'Y:\PSR_Data\PSR_25\PSR_25_Rec2_First35min';

% dirList{1} ='Y:\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634';
% dirList{1} ='Y:\PSR_Data\PSR_18\PSR_18_Rec2_231016_190216';
dirList{1} ='Y:\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639';

%%
dd = 1;
dataDir = dirList{dd};
cd(dataDir);
seizFile = dir('*curated*');
seizFile = fullfile(seizFile.folder, seizFile.name);
EEGfile = dir('analogData.bin');
EEGfile = fullfile(EEGfile.folder,EEGfile.name);

%% LOAD DOWNSAMPLED ECOG DATA
FS_EEG = 1000; % desired EEG sampling frequency
dch = 1; % data channel 
EEG = psr_binLoadData(EEGfile,dch, FS_EEG);

%% LOAD IN SPIKES
spikeArray = psr_makeSpikeArray(dataDir);
spikeArray(34:end) = [];
%% LOAD IN SEIZURES
load(seizFile,'seizures');

%% FIND SEIZURE STARTS AND ENDS (1ST AND LAST TROUGH INDICES)
sstend = psr_findsstend(seizures);
timeLims(:,1) = sstend(:,1)-buff;
timeLims(:,2) = sstend(:,2)+buff;

%% PLOT RASTERS AND CORRESPONDING EEG SIGNAL
spikeScatter = psr_findSpikes(spikeArray,timeLims);
binSize = 0.05; % seconds
for szi = 1:numel(spikeScatter)
    be = timeLims(szi,1):binSize:timeLims(szi,2);
    MUA{szi}(1,:) = be(2:end)-binSize/2; %
    MUA{szi}(2,:) = histcounts(spikeScatter{szi,1},be); 
end
psr_plotEEGandRastersandMUA(EEG,spikeScatter,MUA,timeLims);
