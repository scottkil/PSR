%% Batch SWD, stillness, and motion FR calculations
clear all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

bigSWD = [];  % Initialize big matrix to store it all
bigSWC = [];  % Initialize big matrix to store it allRN = []; % initialize recording number vector to store recording number ID
winSize = 0.06; % 60 ms peri-trough window

for rii = 1:size(recfin,1)
    recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %.1f ======= %%\n',...
        recNum);
    topdir = recfin.Filepath_SharkShark_{rii};
    [SWDprop, SWCprop] = psr_SWDC(topdir,winSize);
    bigSWD = [bigSWD;SWDprop];
    bigSWC = [bigSWC;SWCprop];
end