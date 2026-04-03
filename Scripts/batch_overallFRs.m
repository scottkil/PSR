%% Batch SWD, stillness, and motion FR calculations
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

bigFR = [];  % Initialize big matrix to store it all
for rii = 1:size(recfin,1)
    recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %.1f ======= %%\n',...
        recNum);
    topdir = recfin.Filepath_SharkShark_{rii};
    [FRs] = psr_overallFRs(topdir);
    bigFR = [bigFR; FRs]; % append the MUA values to the matrix
end

%%
