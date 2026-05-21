%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');
simpName = dtbl.SimpleName; % get the structure names
uqrid = unique(dtbl.RecID); % find the

ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%%
alphaThresh = 10^-4;
for rii = 1:numel(ubrs)
    sLog = strcmp(simpName,ubrs{rii});
    iLog = dtbl.Inhibitory;
    pLog = dtbl.MVL_pvals_FDR_adjusted <= alphaThresh;
    totLog = cLog & iLog &  pLog;
    FR{rii,1}{1} = dtbl.nonSWDFR(sLog), dtbl.SWDFR(sLog)];
end