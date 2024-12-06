function [spikeArray, neuronChans] = psr_makeSpikeArray(xdir)
%psr_makeSpikeArray Returns all spikes, along with other information, from a data directory
%
% INPUTS:
%   xdir - path to directory with spike sorted data
% OUTPUTS:
%   spikeArray - a nx1 cell array where each cell has spike times for one neuron
%   neuronChans - a nx1 vector. Each element is the  
%
% Written by Scott Kilianski 
% Updated 2024-10-01
%
%% Function body
FS = 30000;     % sample rate - used for calculating spike times in seconds
origDir = cd;   % store starting directory path, so we can cd back to it at the end of this function
cd(xdir);       % cd to the data directory 

clustinfo = tdfread('cluster_info.tsv');            % get the cluster info from tsv file
goodLog = strcmp(cellstr(clustinfo.group),'good');  % logical vector of 'good' clusters
goodClusts = clustinfo.cluster_id(goodLog);         % get IDs of 'good' clusters'
neuronChans = clustinfo.ch(goodLog);                % get the closest channels on probe
spikeTimes = double(readNPY('spike_times.npy'))/FS; % get spike times and convert to seconds units
spikeClusters = readNPY('spike_clusters.npy');      % get spike Cluster IDs
% spikeLog = ismember(spikeClusters,goodClusts); %logical index for spikes from 'good'-labeled clusters
% goodSpikes = spikeTimes(spikeLog);              % spike times of spikes from 'good' clusters
% spikeIDs = spikeClusters(spikeLog);             % IDs of 
assignSpikes = @(X) spikeTimes(spikeClusters==X); % function to assign spikes to clusters in and output cell array
spikeArray = arrayfun(assignSpikes,goodClusts,...
    'UniformOutput',false);                       % 2nd argument 'goodClusts' defines which clusters you want to get spikes from

% try 
    % TSvec = readNPY('timestamps.npy');
% catch
%     warning('timestamps.npy could not be read or could not be found. Check directory organization to find where timestamps.npy resides');
% end

% %% retrieve spike shank - could add depth later if needed
% spikeShank = zeros(size(spikeIDs));
% for i = 1:numel(goodClusts)
%     cc = goodClusts(i); %current cell
%     chn = spikeCh(i); %current channel
%     if chn < 32
%         shank = 1;
%     elseif chn < 64
%         shank = 2;
%     elseif chn < 96
%         shank = 3;
%     else
%         shank = 4;
%     end
%     cspikes = spikeIDs==cc; %current cluster spikeLog
%     spikeShank(cspikes) = shank;
% end

cd(origDir);
end