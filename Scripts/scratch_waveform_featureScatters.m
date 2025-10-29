%%
clear all; close all; clc

recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

%%
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
    figure; scatter(hlfdur,ttp,'filled');
    ylabel('Trough to peak time (ms)')
    xlabel('Half-amplitude duration (ms)')
    xlim([0 0.6])
    ylim([0 1.5])
    ttlString = sprintf('Recording %d.%d',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    bigTTP = [bigTTP; ttp'];
    bigHLFDUR = [bigHLFDUR; hlfdur'];

end

%% === Scatter Plot without jitter === %
% figure;
% scatter(bigHLFDUR,bigTTP,'k','filled','MarkerFaceAlpha', 0.25, 'MarkerEdgeColor', 'none')
% ylabel('Trough to peak time (ms)')
% xlabel('Half-amplitude duration (ms)')
%% Scatter plot w/jitter === %%
Fs = 30000;                 % your sampling rate
dt_ms = 1000/Fs;            % 0.03333 ms per sample
rng(42);                    % reproducible jitter
jitterFrac = 0.5;           % fraction of one sample step (0.5 => ±Δt/2)
jx = (rand(size(bigHLFDUR)) - 0.5) * 2 * jitterFrac * dt_ms;
jy = (rand(size(bigTTP))    - 0.5) * 2 * jitterFrac * dt_ms;
xj = bigHLFDUR + jx;
yj = bigTTP    + jy;

% Keep physical values nonnegative (optional):
xj = max(xj, 0);
yj = max(yj, 0);

% figure('Color','w');
figure
scatter(xj,yj,'k','filled','MarkerFaceAlpha', 0.25, 'MarkerEdgeColor', 'none')
ylabel('Trough to peak time (ms)')
xlabel('Half-amplitude duration (ms)')
xlim([0 0.6])
ylim([0 1.5])

%% === 2D histogram === %
bEdges = 0:dt:1.5;
figure; 
h = histogram2(bigHLFDUR,bigTTP,bEdges,bEdges,'FaceColor','flat','Normalization','probability');
xlim([0 0.6])
ylim([0 1.5])
ylabel('Trough to peak time (ms)')
xlabel('Half-amplitude duration (ms)')
