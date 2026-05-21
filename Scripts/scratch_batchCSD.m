%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');

%%
recList = [2;3;11;30;31;23;24;29;30;33;34];
for ii = 1:numel(recList)
    k = recList(ii);
    recNum(k) = str2num(sprintf('%d.%d',recfin.Subject_(k), recfin.Recording_(k)));
    topdir = recfin.Filepath_SharkShark_{k};
    CSD = psr_CSD(topdir);
    load(fullfile(topdir,'electrodeLocations.mat'),'electrodeLocations');

    % --- Plotting --- %
    yd = 1:size(CSD.chidx,1);

    figure;
    imagesc(CSD.time,yd,CSD.meanCSD(:,:,1));
    yticks(yd)
    yticklabels(electrodeLocations(CSD.chidx(:,1),2));
    title(sprintf('Rec %.1f - Lateral Shank',recNum(k)));

    figure;
    imagesc(CSD.time,yd,CSD.meanCSD(:,:,2));
    yticks(yd)
    yticklabels(electrodeLocations(CSD.chidx(:,2),2));
    title(sprintf('Rec %.1f - Medial Shank',recNum(k)));


end