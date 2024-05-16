function sb = psr_findSpikeBursts(spikeArray, minIN, minISI)
%% psr_findSpikeBursts Retrieves information about spike bursts
%
% INPUTS:
%   spikeArray - a nx1 cell array where each cell has spike times for one neuron
%   minIN - minimum number of spikes per burst (default: 3)
%   minISI - minimum inter-spike-interval for bursts (in seconds) (default: 7ms/.007s)
%
% OUTPUTS:
%   sb - structure where each element corresponds to 1 neuron with the following fields:
%        starts - time of 1st spike in each burst
%        ends - time of last spike in each burst
%        nspikes - number of spikes in each burst
%        wibMat - a matrix with ISIs between spikes in each burst
%
% Written by Scott Kilianski
% Updated on 2024-05-16
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if ~exist('minIN','var')
    minIN = 3; % minimum number of spike intervals for a burst (e.g. 2 corresponds to a 3-spike burst; 4 corresponds to 5-spike burst)
end
if ~exist('minISI','var')
    minISI = 0.007; % minimum inter-spike-interval for bursts
end

for ni = 1:numel(spikeArray)
    st = spikeArray{ni};                    % spike times for a single neuron
    burstID = zeros(size(st));              % initialize burst ID vector (which burst each spike belongs to)
    ISIlog = diff(st) <= minISI;            % find intervals <= miniISI
    burstLog = [0; ISIlog] | [ISIlog; 0];   % any spike involved in a burst (a burst is at least 2 spikes separated by <= minISI)
    st_burst = st(burstLog);                % spike times of all spikes in any burst
    allBurstISI = [diff(st_burst)];         % get ISIs of all spikes in bursts (ADDING ZERO ISI for 1st spike in burst for sorting purposes)
    sepLog = allBurstISI>minISI;            % get logical index of between-burst ISIs to use for removal later
    ISI_ID = 1+cumsum(sepLog);              % generate distinct IDs for each burst by cumulative summing over a logical vector
    burstID(burstLog) = [1;ISI_ID];         % populate burstID vector so ALL spikes get assigned a burstID (0 if they don't belong to a burst)
    burst_ISI_ID = ISI_ID(~sepLog);         % IDs to only ISIs within bursts (i.e. not between bursts)
    wiBurstISI = allBurstISI(~sepLog);      % Use burst_ISI_ID to index wiBurstISI and build within-burst ISI matrix
    [~,nc] = mode(burst_ISI_ID);            % find how many spikes in the burst with the most spikes
    wibMat = nan(burst_ISI_ID(end),nc);     % initialize within-burst matrix
    
    for idx = unique(burst_ISI_ID)' % for each burst, get the ISIs between all spikes in that burst
        currISIs = wiBurstISI(burst_ISI_ID==idx);
        wibMat(idx,1:length(currISIs)) = currISIs; % 
    end

    [uv, sI, ~] = unique(burstID,'first'); % indices to first spikes in bursts
    [uv, eI, ~] = unique(burstID,'last'); % indices to last spikes in bursts
    if uv(1) == 0 % remove spikes belonging to burst 0 (aka no burst)
        uv(1) = [];
        sI(1) = [];
        eI(1) = [];
    end

    nspikes = (eI-sI)+ones(size(sI));   % calculate the number of spikes per burst
    keepLog = nspikes >= minIN;         % logical vector to keep bursts with >= minIN spikes
    sb(ni).starts = st(sI(keepLog));    
    sb(ni).ends = st(eI(keepLog));       
    sb(ni).nspikes = nspikes(keepLog);  
    sb(ni).wibMat = wibMat(keepLog,:);   
end

end % function end