%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');       % read in data table
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove excluded;


%%
for sii = 1:numel(ubrs)
    cLog = strcmp(simpName,ubrs{sii});
    FRs{sii,1}(:,1) = dtbl.SWDFR(cLog);
    FRs{sii,1}(:,2) = dtbl.StillFR(cLog);
    FRs{sii,1}(:,3) = dtbl.MotionFR(cLog);
end

%% Differences between
for sii = 1:numel(ubrs)
    FRdiff{sii,1}(:,1) = FRs{sii,1}(:,1) - FRs{sii,1}(:,3); % SWD - Moving
    FRdiff{sii,1}(:,2) = FRs{sii,1}(:,2) - FRs{sii,1}(:,3); % Still - Moving
end