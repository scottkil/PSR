%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');
simpName = dtbl.SimpleName; % get the structure names
uqrid = unique(dtbl.RecID); % find the

ubrs = unique(simpName)';
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%%
alphaThresh = 10^-4;
for rii = 1:numel(ubrs)
    sLog = strcmp(simpName,ubrs{rii});
    pLog = dtbl.MVL_pvals_FDR_adjusted <= alphaThresh;
    sigLog(rii,1) = sum(sLog &  pLog);
    sigLog(rii,2) = sum(sLog);
end