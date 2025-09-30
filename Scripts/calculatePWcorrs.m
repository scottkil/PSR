%% === Calculates average pairwise correlations for nonSWD and SWD periods === %
clear all; close all; clc
% --- Set up variables --- %
tdir = '/media/scott2X/PSR_Data/PSR_07/PSR_07_Rec2_230915_135414/'; 
binSize = 0.1; % seconds
buff = 0; % no time buffer
smoothTime = binSize; % no smoothing
FS = 30000; % sampling frequency

% --- Handle timestamps --- %
tsFile = fullfile(tdir,'timestamps.bin');
tsFID = fopen(tsFile);
TS = fread(tsFID,Inf,'int32');
load(fullfile(tdir,'seizures_EEG.mat'),'seizures');
recSE = double([TS(1),TS(end)])./FS; % recording start and end (in seconds)
fclose(tsFID);

% --- Find seizures, get spikes, make Q matrices --- %
[sstend, ctrl_stend] = psr_findsstend(seizures,recSE); % get starts and ends of SWDs
spkdir = fullfile(tdir,'kilosort4/');
[spikeArray, neuronChans, clustIDs] = psr_makeSpikeArray(spkdir);
swdQ = psr_makeSeizQ(spikeArray, sstend, binSize,buff,smoothTime);
ctrlQ = psr_makeSeizQ(spikeArray, ctrl_stend, binSize,buff,smoothTime);

% --- Make the seizure and control R matrices --- %
R.swd = psr_computeRfromQ(swdQ);
R.ctrl = psr_computeRfromQ(ctrlQ);

% --- Get unique pairs and average over all epochs --- %
urLog = logical(triu(ones(size(swdQ{1},1)),1)); % logical vector for unique pairs


%%
for szi = 1:numel(R.swd) % for all SWDs
    % store unique correlations. Each row is seizure. Each column is a unique neuron pair
     swdR(szi,:) = R.swd{szi}(urLog); 
end

for ei = 1:numel(R.ctrl) % for nonSWD epochs
    % store unique correlations. Each row is an epoch. Each column is a unique neuron pair
    ctrlR(ei,:) = R.ctrl{ei}(urLog); % store unique correlations
end


% --- Calculate average correlations for SWDs and control epochs --- %
meanR = mean(swdR, 1); % average over all SWDs
avgCtrlR = mean(ctrlR, 1); % average over all control epochs