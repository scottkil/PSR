%% === Load mean vectors === %%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');

%%
FRs = []; % intiailize FR storage matrix

for ii = 1:size(recfin,1)
    loopClock = tic;
    tdir = recfin.Filepath_SharkShark_{ii};
    fprintf('Working on %s...\n',tdir);

    % --- Plug in processing code here --- %
        spkdir = fullfile(tdir,'kilosort4/');
        [spikeArray, neuronChans, clustIDs] = psr_makeSpikeArray(spkdir);
        load(fullfile(tdir,'seizures_EEG.mat'),'seizures');
        tsFile = fullfile(tdir,'timestamps.bin');
        tsFID = fopen(tsFile);
        TS = fread(tsFID,Inf,'int32');
        fclose(tsFID); % Close the timestamp file after reading
        cFR = psr_calcFR_SWD(spikeArray,seizures, TS);
        FRs = [FRs; cFR]; % Append current firing rates to the storage matrix
    % ------------------------------------ %

    elapsedTime = toc(loopClock);
    fprintf('Completed in %.2f minutes.\n', elapsedTime/60);
end