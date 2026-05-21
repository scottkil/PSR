clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');


%%
MVA = [];
MVL = [];
TOT_SPKS = [];
PVALS = [];
for ii = 1:size(recfin,1)
    loopClock = tic;
    topdir = recfin.Filepath_SharkShark_{ii};
    fprintf('Working on %s...\n',topdir);
    load(fullfile(topdir,'MeanVectors.mat'),'mv');
    MVA = [MVA;mv.a'];
    MVL = [MVL;mv.L'];
    TOT_SPKS = [TOT_SPKS;mv.totspks'];
    PVALS = [PVALS;mv.pvals(:,1)];
    elapsedTime = toc(loopClock);
    fprintf('Completed in %.2f minutes.\n', elapsedTime/60);
end

%%
