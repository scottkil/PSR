%% === Loop through recordings === %
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');

%%
figdir = '/media/scottX/Figures/PSR_Figures/EEG_Rasters/';
for rii = 1:size(recfin,1)
    loopClock = tic;
    topdir = recfin.Filepath_SharkShark_{rii};
    fprintf('Working on %s...\n',topdir);
    fh = psr_plotEEG_SWDs_Rasters(topdir);
    figname = sprintf('%sPSR_%d_Rec_%d.fig',...
        figdir,recfin.Subject_(rii),recfin.Recording_(rii));
    saveas(fh,figname);
    close(fh);
    close gcf
end