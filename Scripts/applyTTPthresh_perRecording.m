%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
ttp_inhbThresh = 0.5; % trough-to-peak duration threshold for classifying inhibitory neurons

%%
WFfile = fullfile('/home/scott/Documents/',...
    'WF_Features.pdf');              % waveform features PDF

dt = 1000*(1/30000);
Fs = 30000;                 % your sampling rate
dt_ms = 1000/Fs;            % 0.03333 ms per sample
rng(42);                    % reproducible jitter
jitterFrac = 0.5;           % fraction of one sample step (0.5 => ±Δt/2)

bigTTP = [];
bigHLFDUR = [];
for rii = 1:size(recfin,1)

    loopClock = tic;
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    currDir = fullfile(recfin.Filepath_SharkShark_{rii},'kilosort4/');

    load(fullfile(currDir,'meanWFs.mat'),'meanWFs');
    ttp = []; hlfdur = []; % initialize vectors to hold data
    for ci = 1:size(meanWFs,1)
        [ttp(ci), hlfdur(ci)] = psr_spikeFeat(meanWFs(ci,:));
    end
    ttlString = sprintf('Recording %d.%d',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    bigTTP = [bigTTP; ttp'];
    bigHLFDUR = [bigHLFDUR; hlfdur'];
    inhbLog = ttp'<ttp_inhbThresh; %
    outName = sprintf('%sInhibitoryLog.mat',currDir);
    save(outName,'inhbLog','-v7.3');
end

% --- Get the big log of inhibitory units --- %
% bigInhbLog = bigTTP < ttp_inhbThresh;
