%% === Summed spiking activity across all SWD-PETHs and save in local directories === %%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
twin = 0.16; % 160ms around each SWD trough (80ms before and after)

for rii = 1:size(recfin,1)
    loopClock = tic;
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    currDir = recfin.Filepath_SharkShark_{rii};
    [spkPETH, binCen] = psr_PETH_units_swd(currDir,twin);
    sum_spkPETH = sum(spkPETH,3);
    save(fullfile(currDir, 'sum_spkPETH.mat'), ...
        'sum_spkPETH', 'binCen','-v7.3'); % Save the spiking PETH data to a file
    toc(loopClock)
end
