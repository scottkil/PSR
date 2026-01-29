%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
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


    % === Prepare jitter for scatter plot below === %
    jx = (rand(size(ttp)) - 0.5) * 2 * jitterFrac * dt_ms;
    jy = (rand(size(hlfdur)) - 0.5) * 2 * jitterFrac * dt_ms;
    xj = hlfdur + jx;
    yj = ttp + jy;

    % Keep physical values nonnegative (optional):
    xj = max(xj, 0);
    yj = max(yj, 0);

    % === Scatter plot w/jitter === %
    cf = figure('Color','w','Visible','off');
    subplot(121);
    scatter(xj,yj,'k','filled','MarkerFaceAlpha', 0.5, 'MarkerEdgeColor', 'none')
    ylabel('Trough to peak time (ms)')
    xlabel('Half-amplitude duration (ms)')
    xlim([0 0.6])
    ylim([0 1.5])
    title(ttlString)

    % === 2D histogram === %
    bEdgesY = 0:dt:1.5;
    bEdgesX = 0:dt:0.6;
    bcX = bEdgesX(2:end)-diff(bEdgesX(1:2));
    bcY = bEdgesY(2:end)-diff(bEdgesY(1:2));
    hc = histcounts2(hlfdur,ttp,bEdgesX,bEdgesY);
    ax = subplot(122);
    imagesc(bcX,bcY,hc);
    set(ax,'YDir','normal')
    ylabel('Trough to peak time (ms)')
    xlabel('Half-amplitude duration (ms)')
    title(ttlString)
    
    drawnow;
    exportgraphics(cf, WFfile,...
    'Append', true);
    delete(cf);

    bigCounts.ttp_vals(rii,:) =  histcounts(ttp,bEdgesY);
    bigCounts.ttp_time  = bcY;
    bigCounts.hlfdur_vals(rii,:) = histcounts(hlfdur, bEdgesX);
    bigCounts.hlfdur_time = bcX;
end

