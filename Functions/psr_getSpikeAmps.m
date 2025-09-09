function ampls = psr_getSpikeAmps(topdir,nWf)
%% psr_getSpikeAmps Returns spike amplitudes (in uV) for subsample of spikes
%
% INPUTS:
%   topdir - full path to directory with output from Kilosort
%   nWf - number of waveforms (spikes). Default is 2000
% OUTPUTS:
%   ampls - amplitudes in cell array (in uV)
%           1st column is clusterID (0-indexed). 
%           2nd column are peak amplitudes
%           This array is also saved in topdir
%
% Written by Scott Kilianski
% Updated on 2025-09-08
% ------------------------------------------------------------ %
%% Function Body %%
% === Handle Inputs and Set Static Variables === %
if nargin < 2 || ~isempty(nWf); nWf = 2000; end  % number of waveforms default
binFile = 'combined.bin';   % name of binary file
numChans = 256;             % number of channels
scaleFactor = 0.195;        % int16-to-uV conversion factor for Intan data
wfWin = [-40 41];           % waveform sample window (default is 82 samples)
winVec = wfWin(1):wfWin(2); % indexing window vector
baseMat = int64(repmat(winVec,nWf,1)); % base matrix used for indexing into raw data later

% === Load and map relevant data === %
md = psr_mapBinData(fullfile(topdir,binFile),numChans); % memory map raw data from binary file
clusterInfo = readcell(fullfile(topdir,'cluster_info.tsv'), ...
    'FileType','text','Delimiter','\t');
chCol = find(strcmp(clusterInfo(1,:),'ch'));
spikeTimes = readNPY(fullfile(topdir,'spike_times.npy')); % load in all spike times
spikeClusters = readNPY(fullfile(topdir,'spike_clusters.npy'));

% === Set up high-pass filter for filtering spike waveforms === %
fs = 30000; %
Fc = 300; % high-pass cutoff frequency (Hz)
[b, a] = butter(3, Fc/(fs/2), 'high'); % high-pass Butterworth filter

% === Loop through each cluster to get amplitudes === %
cIDlist = cell2mat(clusterInfo(2:end,1));
loopClock = tic;
parfor ci = 1:numel(cIDlist)
    % fprintf('\rCluster %d of %d...',ci,numel(cIDlist))
    cID = cIDlist(ci);                              % current cluster ID
    stcc = spikeTimes(spikeClusters==cID); % spike times for current cluster
    cRow = find(cellfun(@(X) isequal(X,cID),...
        clusterInfo(:,1)));                         % find matching row in Cluster Info table
    bestChan = clusterInfo{cRow,chCol};             % find the current cluster's best channel (highest amplitude)
    bestChan = bestChan + 1;                        % convert from 0-indexed to 1-indexed
    
    if numel(stcc) < nWf     % if the current cluster has few spikes, set the subsample to total # spikes
        cnWf = numel(stcc);
    else
        cnWf = nWf;
    end
    stss = stcc(randperm(numel(stcc),cnWf)); % get spikes times for current subsample
    badLog = (wfWin(1)+stss) <= 0 | (wfWin(2) + stss) > size(md.Data.ch,2); % if spikes are too close to beginning or end, remove
    stss(badLog) = [];                       % remove bad spikes (too close to beginning or end of recording)
    unWf = sum(~badLog);                     % updated # of waveforms if some are removed
    bMat = baseMat(1:unWf,:);  % modified base matrix (important for clusters with <nWf spikes) 
    modMat = int64(repmat(stss,1, ...
        size(bMat,2)));                   % spike time matrix to use in indexing below
    indMat = bMat + modMat;               % actual indexing matrix

    % === Index to get waveforms on best channel === %
    cwfd = md.Data.ch(bestChan,indMat)'; % pulling waveform data from file
    cwfd = double(reshape(cwfd,unWf, ...
        numel(winVec)))*scaleFactor;     % reshaping it so every row is 1 spike and scaling to uV
    BPdata = filtfilt(b, a, cwfd')';     % band-pass filter the waveforms
    temp1{ci,1} = cID;                   % save cluster ID
    temp2{ci,1} = abs(min(BPdata,[],2)); % save the minimum value (peak amplitude)
    temp3{ci,1} = BPdata;                % save the actual waveforms
    % fprintf('%.2f seconds',...
    %     toc(loopClock));
end

ampls = cat(2,temp1,temp2,temp3);

fprintf('Saving spike amplitudes and waveforms to\n%s\n...\n',fullfile(topdir,'amplitudes.mat')); % go to next line in command window
fprintf('\n');
save(fullfile(topdir,'amplitudes.mat'),'ampls','-v7.3');
end % function end