%% === Loop through recordings === %
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');

%%
for ii = 1:size(recfin,1)
    recNum(ii) = str2num(sprintf('%d.%d',recfin.Subject_(ii), recfin.Recording_(ii)));
    topdir = recfin.Filepath_SharkShark_{ii};
    fprintf('Working on %.1f...\n',recNum(ii));
    [durs{ii,1}, PFs{ii,1}] = psr_SWDstats(topdir);
end

%%
meanDurs = cellfun(@mean,durs);
meanPFs = cellfun(@mean,PFs);