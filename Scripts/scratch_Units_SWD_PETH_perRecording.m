%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

for rii = 1:size(recfin,1)
    topdir = recfin.Filepath_SharkShark_{rii};
    twin = 0.16;
    [spkPETH, binCen] = psr_PETH_units_swd(topdir,twin);
    cinfo = readtable(fullfile(topdir,'CellInfo.csv'),...
        'Delimiter',',');
    inhibLog = cinfo.Inhibitory == 1;

    %
    spp = sum(spkPETH,3);

    %
    figure;

    subplot(211);
    bar(binCen,sum(spp(~inhibLog,:)));
    hold on
    xline(0,'r');
        title(sprintf('Recording %d.%d',...
        recfin.Subject_(rii),recfin.Recording_(rii)));
    subplot(212);
    bar(binCen,sum(spp(inhibLog,:)));
    hold on;
    xline(0,'r');
    title('Putative Inhibitory Neurons')
    xlabel('Time from SWD Trough')
end

