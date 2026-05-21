%%
% --- Counting neurons by area and by layer --- %
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');       % read in data table
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names

%%
uR = unique(dtbl.RecID);
strucCell = {};
for urii =1:numel(uR)
    cLog = dtbl.RecID==uR(urii);
    strucCell= [strucCell;unique(simpName(cLog))];
end

%%
sum(strcmp(strucCell,'Caudoputamen'))
sum(strcmp(strucCell,'Somatosensory'))
sum(strcmp(strucCell,'Frontal'))
sum(strcmp(strucCell,'Visual'))
sum(strcmp(strucCell,'Hipp'))