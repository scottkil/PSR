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
%
% Written by Scott Kilianski
% Updated on 2025-06-04
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
FS = 30000;                 % sampling frequency (samples/sec)
ISIVthresh_sec = 0.0015;     % ISI threshold ( in seconds)
binsz = 60;                 % bin size in seconds (for presence ratio)
minSpikeCountPerBin = 1;    % minimum number of spikes per bin needed (for presence ratio calculation)
QMfile = fullfile(ksdir,...
    'QM.pdf');              % quality metrics PDF
if exist(QMfile,'file')
    fprintf('Deleting %s...\n',QMfile)
    delete(QMfile);
end
tsFile = fullfile(ksdir,...
    'timestamps.bin');      % timestamp file
cgFile = fullfile(ksdir,...
    'cluster_group.tsv');   % cluster group file
clusttab = readtable(cgFile,...
    'FileType','text',...
    'Delimiter', '\t');
cIDs = clusttab.cluster_id;


d = memmapfile(tsFile,...
    'Format','int32');      % memory map to load data
nSamps = numel(d.Data);     % divide number of total samples (across all channels) by number of channels to find number of samples
tSec = nSamps/FS;           % total recording time (in seconds);
bedges = 0:binsz:tSec;      % bin edges
numbins = length(bedges)-1; % # bins

ampsFile = fullfile(ksdir,'amplitudes.npy');        %
clustFile = fullfile(ksdir,'spike_clusters.npy');   %
spktimeFile = fullfile(ksdir,'spike_times.npy');    % spike_times filepath
spkamps = readNPY(ampsFile);                        %
spkclusts = readNPY(clustFile);                     %
spktimes = double(readNPY(spktimeFile))./FS;        % spike times (timestamps units)

assignTimes = @(X) spktimes(spkclusts==X);  % function to assign spikes to clusters in and output cell array
spkt = arrayfun(assignTimes,...
    unique(spkclusts),...
    'UniformOutput',false);                 %

assignAmps = @(X) spkamps(spkclusts==X); % function to assign spikes to clusters in and output cell array
spka = arrayfun(assignAmps,unique(spkclusts),...
    'UniformOutput',false);

isic = cellfun(@diff,spkt,'UniformOutput',false);       % interval spike intervals
ISIviol = cellfun(@(X) sum(X<=ISIVthresh_sec),isic);    % ISI violations
spkcount = cellfun(@numel,spka);
FR = spkcount./tSec; % firing rate
ISIV = ISIviol./spkcount;
spkCounts = cellfun(@(X) histcounts(X,bedges),...
    spkt,'UniformOutput',false);                        % number of spikes per bin
spkCounts = cell2mat(spkCounts);                        % converting spikes-per-bin to matrix
bins_with_spikes = spkCounts>=minSpikeCountPerBin;      % labeling bins as having enough spikes
PR = sum(bins_with_spikes,2) ./ numbins;                % presence ratio

for ni = 1:numel(spka)
    fprintf('Unit %d fitting Gaussian...\n',ni-1);
    if ni == 121
        disp('p');
    end
    try
        gfit = psr_fitGaussian(spka{ni});
        PMS(ni,1) = normcdf(min(spka{ni}), gfit.mu, gfit.sig); % proportion of missing spikes
        psr_PlotAndAppend(gcf,ISIV,FR,PR,PMS,cIDs,ni,QMfile); %
    catch
        PMS(ni,1) = NaN;
    end
end

% --- Put everything in output structure --- %
clmet.PMS = PMS;
clmet.PR = PR;
clmet.ISIV = ISIV;
clmet.FR = FR;
clmet.unitID = cIDs;

end % function end


function psr_PlotAndAppend(gcf,ISIV,FR,PR,PMS,cIDs,ni,QMfile)

% --- Plotting text --- %
for ti = 1:5
    switch ti
        case 1
            strng = sprintf('PR: %.3f',PR(ni));
            tbpos = [0.1, 0.7, 0.4, 0.1];
        case 2
            strng = sprintf('FR: %.3f',FR(ni));
            tbpos = [0.1, 0.55, 0.4, 0.1];
        case 3
            strng = sprintf('ISIV: %.3f',ISIV(ni));
            tbpos = [0.1, 0.4, 0.4, 0.1];
        case 4
            strng = sprintf('PMS: %.3f',PMS(ni));
            tbpos = [0.1, 0.25, 0.4, 0.1];
        case 5
            strng = sprintf('Unit #%d',cIDs(ni));
            tbpos = [0.1, 0.85, 0.4, 0.1];
    end

    annotation('textbox', tbpos, ...  % [x y width height] in normalized units
        'String', strng, ...
        'EdgeColor', 'none', ...
        'Color', 'k',...
        'FontSize',16);
end

set(gcf().Children,'FontSize',16);
drawnow;
exportgraphics(gcf, QMfile,...
    'Append', true);
close(gcf);  

end % function end
