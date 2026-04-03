%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');       % read in data table
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names
ubrs = unique(simpName);

bigFR = []; % Initialize bigFR to store firing rates
nn = [];    % Initialize nn to store neuron counts
SN = {};    % Initialize SN to store structure names
for rii = 1:size(recfin,1)
        recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %.1f ======= %%\n',...
        recNum);
    cLog = dtbl.RecID == recNum;
    subTable = dtbl(cLog,:);
    BRs = unique(subTable.SimpleName);
    % Calculate the firing rates for each unique structure
    for b = 1:length(BRs)
        structureData = subTable(strcmp(subTable.SimpleName, BRs{b}), :);
        cStillFR = mean(structureData.StillFR); % still FR
        cMotionFR = mean(structureData.MotionFR); % motion FR
        cSWDFR = mean(structureData.SWDFR);  % FR during SWD
        bigFR = [bigFR; cSWDFR, cStillFR, cMotionFR];
        nn = [nn; size(structureData,1)];
        SN = [SN; BRs{b}];
    end

end

stateMUAtable = table(bigFR,nn,SN);