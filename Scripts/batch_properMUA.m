clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');

dsFS = 10000;
binW = 0.001;

bigP = [];
for rii = 1:size(recfin,1)
    topdir = recfin.Filepath_SharkShark_{rii};
    fprintf('Working on %s...\n',topdir);
    load(fullfile(topdir,'MUA.mat'),'MUA');
    seizFile = fullfile(topdir,'seizures_EEG.mat');
    [TT, ttID] = psr_getTroughTimes(seizFile);
    for ti = 1:numel(TT)
        
    


    % figure;
    % sh1_mua = cell2mat(MUA.data(:,1));
    % yd = 1:size(sh1_mua,1);
    % imagesc(MUA.time,yd,sh1_mua);
end