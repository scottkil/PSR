function [spikeArray, neuronChans, clustIDs] = psr_makeSpikeArray(xdir)
%psr_makeSpikeArray Returns all spikes, along with other information, from a data directory
%
% INPUTS:
%   xdir - path to directory with spike sorted data
% OUTPUTS:
%   spikeArray - a nx1 cell array where each cell has spike times for one neuron
%   neuronChans - a nx1 vector. Each element is the corresponding cluster's
%                 'best' channel (highest amplitude). 0-indexed
%   clustIDs - cluster IDs
%
% Written by Scott Kilianski 
% Updated 2025-09-23
%
%% Function body
FS = 30000;     % sample rate - used for calculating spike times in seconds
origDir = cd;   % store starting directory path, so we can cd back to it at the end of this function
cd(xdir);       % cd to the data directory 

clustinfo = tdfread('cluster_info.tsv');            % get the cluster info from tsv file
goodLog = strcmp(cellstr(clustinfo.group),'good');  % logical vector of 'good' clusters
goodClusts = clustinfo.cluster_id(goodLog);         % get IDs of 'good' clusters'
neuronChans = clustinfo.ch(goodLog);                % get the closest channels on probe
clustIDs = clustinfo.cluster_id(goodLog);           %
spikeTimes = double(readNPY('spike_times.npy'))/FS; % get spike times and convert to seconds units
spikeClusters = readNPY('spike_clusters.npy');      % get spike Cluster IDs
% spikeLog = ismember(spikeClusters,goodClusts); %logical index for spikes from 'good'-labeled clusters
% goodSpikes = spikeTimes(spikeLog);              % spike times of spikes from 'good' clusters
% spikeIDs = spikeClusters(spikeLog);             % IDs of 
assignSpikes = @(X) spikeTimes(spikeClusters==X); % function to assign spikes to clusters in and output cell array
spikeArray = arrayfun(assignSpikes,goodClusts,...
    'UniformOutput',false);                       % 2nd argument 'goodClusts' defines which clusters you want to get spikes from
cd(origDir);

end