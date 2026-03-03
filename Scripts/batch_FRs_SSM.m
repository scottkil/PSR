%% Batch SWD, stillness, and motion FR calculations
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

bigSSM = [];  % Initialize big matrix to store it all
bigMUA = [];  % initialize matrix for MUA
RN = []; % initialize recording number vector to store recording number ID
for rii = 1:size(recfin,1)
        recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %.1f ======= %%\n',...
        recNum);
    topdir = recfin.Filepath_SharkShark_{rii};
    [stateFR, MUA_FR] = psr_FRs_SSM(topdir);
    bigSSM = [bigSSM; stateFR];  % append the state spike rate results to bigSSM
    bigMUA = [bigMUA; MUA_FR]; % append the MUA values to the matrix
end