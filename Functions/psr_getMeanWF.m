function meanWFs = psr_getMeanWF(topdir)
%% psr_getMeanWF Returns mean waveforms of all clusters on their best channels
%
% INPUTS:
%   topdir - full path to top-level directory
%
% OUTPUTS:
%   meanWFs - #clusters x #time points per waveform. Values are in uV units
%
% Written by Scott Kilianski
% Updated on 2025-10-28
% ------------------------------------------------------------ %
%% Function Body %%
% === Handle Inputs and Set Static Variables === %
binFile = 'combined.bin';   % name of binary file
numChans = 256;             % number of channels
scaleFactor = 0.195;        % int16-to-uV conversion factor for Intan data
wfWin = [-40 41];           % waveform sample window (default is 82 samples)
winVec = wfWin(1):wfWin(2); % indexing window vector
ksdir = fullfile(topdir,'kilosort4/');
% === Load and map relevant data === %
md = psr_mapBinData(fullfile(topdir,binFile),numChans); % memory map raw data from binary file
clusterInfo = readcell(fullfile(ksdir,'cluster_info.tsv'), ...
    'FileType','text','Delimiter','\t');
groupCol = find(strcmp(clusterInfo(1,:),'group'));  % index to group column
groop = clusterInfo(2:end,groupCol); % cluster groups
chCol = find(strcmp(clusterInfo(1,:),'ch'));
spikeTimes = readNPY(fullfile(ksdir,'spike_times.npy')); % load in all spike times
spikeClusters = readNPY(fullfile(ksdir,'spike_clusters.npy'));

% === Set up high-pass filter for filtering spike waveforms === %
fs = 30000; %
Fc = 300; % high-pass cutoff frequency (Hz)
[b, a] = butter(3, Fc/(fs/2), 'high'); % 3rd order high-pass Butterworth filter

% === Loop through each cluster to get amplitudes === %
goodClog = strcmp(groop,'good'); % find good clusters
cIDlist = cell2mat(clusterInfo(2:end,1));
cIDlist = cIDlist(goodClog); % find good clusters

% === Main Processing Loop Getting Mean Waveforms === %
for ci = 1:numel(cIDlist)
    fprintf('Cluster %d of %d...\n',ci,numel(cIDlist))
    cID = cIDlist(ci);                              % current cluster ID
    stcc = spikeTimes(spikeClusters==cID); % spike times for current cluster
    cRow = find(cellfun(@(X) isequal(X,cID),...
        clusterInfo(:,1)));                         % find matching row in Cluster Info table
 
    bestChan = clusterInfo{cRow,chCol};             % find the current cluster's best channel (highest amplitude)
    bestChan = bestChan + 1;                        % convert from 0-indexed to 1-indexed

    badLog = (wfWin(1)+stcc) <= 0 | (wfWin(2) + stcc) > size(md.Data.ch,2); % if spikes are too close to beginning or end, remove
    stcc(badLog) = [];                       % remove bad spikes (too close to beginning or end of recording)
    unWf = sum(~badLog);                     % updated # of waveforms if some are removed

    % === If cluster has no viable spikes, move to next next === %
    if ~unWf
        
        continue
    end

    % === Preparing indices to 
    bMat = int64(repmat(winVec,unWf,1));  % base matrix
    modMat = int64(repmat(stcc,1, ...
        size(bMat,2)));                   % spike time matrix to use in indexing below
    indMat = bMat + modMat;               % actual indexing matrix
    
    % === Iterative over spikes (useful if limited RAM === %
    % cwfd = []; % intialize current waveform data
    % for spki = 1:numel(stcc)
    %     indVec = stcc(spki)+int64(winVec);
    %     cwfd(spki,:) = md.Data.ch(bestChan,indVec)';
    % end
    % cwfd = double(cwfd)*scaleFactor;

    % === All spikes all at once (useful if plenty of free RAM === %
    cwfd = md.Data.ch(bestChan,indMat)'; % pulling waveform data from file
    cwfd = double(reshape(cwfd,unWf, ...
        numel(winVec)))*scaleFactor;     % reshaping it so every row is 1 spike and scaling to uV
    
    BPdata = filtfilt(b, a, cwfd')';     % band-pass filter the waveforms
    meanWFs(ci,:) = mean(BPdata,1);      % compute mean waveform for the current cluster

end % Processing loop end

end % function end