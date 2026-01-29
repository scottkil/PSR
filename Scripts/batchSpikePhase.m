%% === Loop through recordings === %
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');

%%
for ii = 1:size(recfin,1)
    loopClock = tic;
    xdir = recfin.Filepath_SharkShark_{ii};
    fprintf('Working on %s...\n',xdir);
    psr_spikePhaseAndPlot(xdir);
    elapsedTime = toc(loopClock);
    fprintf('Completed in %.2f minutes.\n', elapsedTime/60);
end