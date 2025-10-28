function [PWC] = psr_computePWcorrs(tdir,simpName)
%% psr_computePWcorrs Calculates average pairwise correlations for nonSWD and SWD periods
%
% INPUTS:
%   tdir - top-level directory for recording
%   simpName - (optional) cell array with names of brain region for each neuron
%
% OUTPUTS:
%   PWC - a structure with the following fields:
%             swd:  pairwise correlations during SWD
%             ctrl:  pairwise correlations during nonSWD (control) epochs
%             pairNames: cell array with pairs of brain regions for corresponding correlations in the following format:
%                       BR#1-BR#2 (e.g. 'Caudoputamen-Somatosensory')
%
% Written by Scott Kilianski
% Updated on 2025-09-29
% ------------------------------------------------------------ %
%% === Function Body Below === %
% --- User-controlled variables --- %
binSize = 0.1;        % seconds
buff = 0;             % no time buffer
smoothTime = binSize; % no smoothing
FS = 30000;           % sampling frequency

% --- Load and handle timestamps --- %
tsFile = fullfile(tdir,'timestamps.bin');  % load timestamps
tsFID = fopen(tsFile);                     % open timestamps file
TS = fread(tsFID,Inf,'int32');             % read in timestamps data
load(fullfile(tdir,'seizures_EEG.mat'),... 
    'seizures');                           % load seizures
recSE = double([TS(1),TS(end)])./FS;       % recording start and end (in seconds)
fclose(tsFID);                             % close timestamps file

% --- Find seizures, get spikes, make Q matrices --- %
[sstend, ctrl_stend] = psr_findsstend(seizures,recSE); % get starts and ends of SWDs
spkdir = fullfile(tdir,'kilosort4/');                  % kilosort output directory
[spikeArray, neuronChans, clustIDs] = psr_makeSpikeArray(spkdir);       % get the spike times
Q.swd = psr_makeSeizQ(spikeArray, sstend, binSize,buff,smoothTime);      % SWD Q matrices
Q.ctrl = psr_makeSeizQ(spikeArray, ctrl_stend, binSize,buff,smoothTime); % non SWD Q matrices

% --- Make the seizure and control R matrices --- %
R.swd = psr_computeRfromQ(Q.swd);    % compute R matrices for SWDs
R.ctrl = psr_computeRfromQ(Q.ctrl);  % compute R matrices for control epochs

% --- Assign each pair a brain structure - brain structure name --- %
if exist("simpName",'var')
    for ii = 1:size(spikeArray,1)
        iiString = simpName{ii}; % current row string
        for jj = 1:size(spikeArray,1)
            jjString = simpName{jj};
            pairString{ii,jj} = sprintf('%s-%s',iiString,jjString);
        end
    end
else
    pairString = []; % return empty if simpName is not given
end

% --- Get unique pairs and average over all epochs --- %
urLog = logical(triu(ones(numel(spikeArray)),1)); % logical vector for unique pairs
for szi = 1:numel(R.swd) % for all SWDs
     swdR(szi,:) = R.swd{szi}(urLog); % store unique correlations. Each row is an epoch. Each column is a unique neuron pair
end
for ei = 1:numel(R.ctrl) % for nonSWD epochs
    ctrlR(ei,:) = R.ctrl{ei}(urLog); % store unique correlations. Each row is an epoch. Each column is a unique neuron pair
end

% --- Store in structure for output --- %
PWC.pairNames = pairString(urLog); 
PWC.swd = swdR;   % average over all SWDs
PWC.ctrl = ctrlR; 

end % function end