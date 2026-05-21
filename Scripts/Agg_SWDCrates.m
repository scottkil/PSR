% --- Get all significantly phase-locked neurons --- %
% --- Get neurons per area

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
    pLog = dtbl.MVL_pvals_FDR_adjusted <= alphaThresh; % check for significant phase-locking
    SWDrate{rii,1} = dtbl.SWDPrate(sLog & pLog);
    cycleRate{rii,1} = dtbl.SWCPrate(sLog & pLog);
end

