%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

%%
simpName = dtbl.SimpleName;
ubrs = unique(simpName);

%%
frs = {};
froutlier = 150; % outlier limit to remove
for sii = 1:numel(ubrs)
    cLog = strcmp(simpName,ubrs{sii});
    inLog = dtbl.nonSWDFR < froutlier & dtbl.SWDFR < froutlier;
    frs{sii,2}(:,1) = dtbl.nonSWDFR(cLog&inLog);
    frs{sii,2}(:,2) = dtbl.SWDFR(cLog&inLog);
    % frs{sii,3}(:,1) = log(dtbl.nonSWDFR(cLog));   % log transform
    % frs{sii,3}(:,2) = log(dtbl.SWDFR(cLog));      % log transform
    frs{sii,1} = ubrs{sii};
end


%%
outMat = [];
for sii = 1:size(frs,1)
    tmp(1,1) = mean(frs{sii,2}(:,1));
    tmp(1,2) = std(frs{sii,2}(:,1));
    tmp(1,3) = size(frs{sii,2},1);

    tmp(2,1) = mean(frs{sii,2}(:,2));
    tmp(2,2) = std(frs{sii,2}(:,2));
    tmp(2,3) = size(frs{sii,2},1);
    outMat = [outMat, tmp]; % Append the results to the output matrix
end