function clmet = psr_checkClusters(ksdir)
%% psr_checkClusters Returns metrics for clusters
%
% INPUTS:
%   ksdir - Directory with output from kilosort/phy
%
% OUTPUTS:
%   clmet - cluster metrics structure with following fields:
%           PMS: estimated proportion missing spikes
%           ISIV: ISI violation proportion
%           PR: presence ratio
%           FR: firing rate (spks/s) for whole recording
%           A: amplitude of subsample of spikes (in uV)
%           NZ: average RMS on cluster's best channel (in uV)
%           SNR: signal-to-noise ratio
%           BC: best channel (0-indexed)
%
% Written by Scott Kilianski
% Updated on 2025-09-08
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
FS = 30000;                 % sampling frequency (samples/sec)
ISIVthresh_sec = 0.0015;    % ISI threshold ( in seconds)
binsz = 60;                 % bin size in seconds (for presence ratio)
minSpikeCountPerBin = 1;    % minimum number of spikes per bin needed (for presence ratio calculation)
SNRthresh = 2;              % SNR threshold for determining cuttoff for PMS metric

QMfile = fullfile(ksdir,...
    'QualityMetrics.pdf');              % quality metrics PDF
if exist(QMfile,'file')
    fprintf('Deleting %s...\n',QMfile)
    delete(QMfile);
end

% === Load in necessary files for kilosorted directory === %
inFile = fullfile(ksdir,...
    'cluster_info.tsv');    % cluster info file
tsFile = fullfile(ksdir,...
    'timestamps.bin');      % timestamp file
% cgFile = fullfile(ksdir,...
%     'cluster_group.tsv');   % cluster group file
% clusttab = readtable(cgFile,...
%     'FileType','text',...
%     'Delimiter', '\t');
clinfo = readcell(inFile,...
    'FileType','text',...
    'Delimiter', '\t');
idCol = strcmp(clinfo(1,:),'cluster_id');
cIDs = clinfo(2:end,idCol);
chCol = strcmp(clinfo(1,:),'ch');
bestCH = clinfo(2:end,chCol);
bestCH = cell2mat(bestCH)+1; % convert from 0-indexed to 1-indexed

% === Setup for spike times, amplitudes, SNR, etc === %
d = memmapfile(tsFile,...
    'Format','int32');      % memory map to load data
nSamps = numel(d.Data);     % divide number of total samples (across all channels) by number of channels to find number of samples
tSec = nSamps/FS;           % total recording time (in seconds);
bedges = 0:binsz:tSec;      % bin edges
numbins = length(bedges)-1; % # bins
rmsFile = fullfile(ksdir,'rms.mat');
ampsFile = fullfile(ksdir,'amplitudes.mat');        % actual spike amplitudes (in uV)
clustFile = fullfile(ksdir,'spike_clusters.npy');   %
spktimeFile = fullfile(ksdir,'spike_times.npy');    % spike_times filepath
tampsFile = fullfile(ksdir,'amplitudes.npy');            % template amplitudes
load(ampsFile,'ampls');                             % read in subsample of spike times
load(rmsFile,'rms');                                % pre-calculated RMS for all channels (root mean squared)
spkclusts = readNPY(clustFile);                     %
spktimes = double(readNPY(spktimeFile))./FS;        % spike times (timestamps units)
spktamps = double(readNPY(tampsFile));              % read in spike template amplitudes

% === Assigning spike times, amplitues, best channels, RMS, etc === %
assignTimes = @(X) spktimes(spkclusts==X);  % function to assign spikes to clusters in and output cell array
spkt = arrayfun(assignTimes,...
    unique(spkclusts),...
    'UniformOutput',false);                 %

% assignAmps = @(X) spktamps(spkclusts==X); % function to assign spikes to clusters in and output cell array
% spka = arrayfun(assignAmps,unique(spkclusts),...
%     'UniformOutput',false); % spike template amplitudes
spkamps = ampls(:,2);   % spike actual amplitudes (microvolts)
spka = spkamps;         % for legacy purposes
spkWF = ampls(:,3);     % subsample of spike waveforms
meanRMS = mean(rms.vals,2);                             % mean RMS per channel (microvolts)

isic = cellfun(@diff,spkt,'UniformOutput',false);       % interval spike intervals
ISIviol = cellfun(@(X) sum(X<=ISIVthresh_sec),isic);    % ISI violations
spkcount = cellfun(@numel,spkt);
FR = spkcount./tSec; % firing rate
ISIV = ISIviol./spkcount;
spkCounts = cellfun(@(X) histcounts(X,bedges),...
    spkt,'UniformOutput',false);                        % number of spikes per bin
spkCounts = cell2mat(spkCounts);                        % converting spikes-per-bin to matrix
bins_with_spikes = spkCounts>=minSpikeCountPerBin;      % labeling bins as having enough spikes
PR = sum(bins_with_spikes,2) ./ numbins;                % presence ratio
A = cellfun(@mean, spkamps);                            % mean amplitude (microvolts)
NZ = meanRMS(bestCH);                                   % mean RMS on each cluster's best channel (noise)
SNR = A./NZ;                                            % SNR
BC = bestCH-1;                                          % best channel

% === Loop for fitting Gaussians to each cluster's spike amplitude distribution === %
parfor ni = 1:numel(spka)
    try
        [gfit, fls(ni)] = psr_fitGaussian(double(spka{ni}));
        cuttoffVal  = NZ(ni)*SNRthresh; % cuttoff value = noise (RMS) x SNR threshold
        PMS(ni,1) = normcdf(cuttoffVal, gfit.mu, gfit.sig); % proportion of missing spikes
        % PMS(ni,1) = normcdf(min(spka{ni}), gfit.mu, gfit.sig); % proportion of missing spikes
    catch
        PMS(ni,1) = NaN;
    end

end

% === Loop for plotting and appending each cluster's report === &
cf = figure("Position", [850, 120, 1037, 902],...
    'Visible','off');
for ni = 1:numel(spka)
        fprintf('Unit %d, generating report...\n',cIDs{ni});
    clf(cf);
    psr_PlotAndAppend(cf,ISIV,FR,PR,PMS,cIDs,A,NZ,SNR,BC,ni,QMfile,fls,spka,spkWF,SNRthresh); %
end


% --- Put everything in output structure and save --- %
clmet.PMS = PMS;
clmet.PR = PR;
clmet.ISIV = ISIV;
clmet.FR = FR;
clmet.unitID = cIDs;
clmet.A = A;
clmet.NZ = NZ;
clmet.SNR = SNR;
clmet.BC = BC;
save(fullfile(ksdir,'cluster_metrics2.mat'),'clmet');

end % function end


function psr_PlotAndAppend(cf,ISIV,FR,PR,PMS,cIDs,A,NZ,SNR,BC,ni,QMfile,fls,spka,spkWF,SNRthresh)

% --- Plot Spike Amplitude Histogram --- %
sp1 = subplot(2,3,2:3);
plot(mean(spkWF{ni},1));
xlim tight
title('Mean Waveform');
sp2 = subplot(2,3,5:6);
histogram(spka{ni},'Normalization','pdf')
hold on
plot(fls(ni).x, fls(ni).y, 'r--', 'LineWidth', 2, 'DisplayName', 'Fitted Gaussian');
xlim tight
yl = sp2.YLim;
plot(ones(2,1).*SNRthresh*NZ(ni),yl,'k--');
hold off

% --- Plotting text --- %
for ti = 1:9
    switch ti
        case 1
            strng = sprintf('PR: %.3f',PR(ni));
            tbpos = [0.1, 0.4, 0.4, 0.05];
        case 2
            strng = sprintf('FR: %.3f',FR(ni));
            tbpos = [0.1, 0.5, 0.4, 0.05];
        case 3
            strng = sprintf('ISIV: %.3f',ISIV(ni));
            tbpos = [0.1, 0.3, 0.4, 0.05];
        case 4
            strng = sprintf('PMS: %.3f',PMS(ni));
            tbpos = [0.1, 0.2, 0.4, 0.05];
        case 5
            strng = sprintf('Unit #%d',cIDs{ni});
            tbpos = [0.1, 0.9, 0.4, 0.05];
        case 6
            strng = sprintf('Amplitude: %.2fuV',A(ni));
            tbpos = [0.1, 0.8, 0.4, 0.05];
        case 7
            strng = sprintf('Noise: %.2fuV',NZ(ni));
            tbpos = [0.1, 0.7, 0.4, 0.05];
        case 8
            strng = sprintf('SNR: %.2f',SNR(ni));
            tbpos = [0.1, 0.6, 0.4, 0.05];
        case 9
            strng = sprintf('BC: %d',BC(ni));
            tbpos = [0.1, 0.1, 0.4, 0.05];
    end

    annotation('textbox', tbpos, ...  % [x y width height] in normalized units
        'String', strng, ...
        'EdgeColor', 'none', ...
        'Color', 'k',...
        'FontSize',16);
end

set(cf().Children,'FontSize',16);
drawnow;
exportgraphics(cf, QMfile,...
    'Append', true);
% close(gcf);

end % function end
