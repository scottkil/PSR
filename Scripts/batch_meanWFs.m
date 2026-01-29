%%
clear all; close all; clc

recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

%%
for rii = 1:size(recfin,1)
    loopClock = tic;
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    topdir = recfin.Filepath_SharkShark_{rii};
    meanWFs = psr_getMeanWF(topdir);
    outName = sprintf('%skilosort4%smeanWFs.mat',topdir,filesep);
    save(outName,'meanWFs','-v7.3');
    fprintf('Took %.2f minutes\n',toc(loopClock)/60);
end

%%
