function Rmean = psr_plotCorrMats(tdir,simpName)
%% psr_plotCorrMats Plots average correlation matrices for nonSWD and SWD periods
%
% INPUTS:
%   tdir - top-level directory for recording
%   simpName - cell array with names of brain region for each neuron
%
% OUTPUTS:
%   Rmean - a structure with the following fields:
%             swd:   average pairwise correlations during SWD
%             ctrl:  average pairwise correlations during nonSWD (control/baseline) epochs
%             names: brain regions for each unit (e.g. 'Caudoputamen','Somatosensory')
%
% Written by Scott Kilianski
% Updated on 2026-02-23
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

[simpName_sorted, sortIDX] = sort(simpName); 
spikeArray = spikeArray(sortIDX); % % sort by brain region name



Q.swd = psr_makeSeizQ(spikeArray, sstend, binSize,buff,smoothTime);      % SWD Q matrices
Q.ctrl = psr_makeSeizQ(spikeArray, ctrl_stend, binSize,buff,smoothTime); % non SWD Q matrices

% --- Make the seizure and control R matrices --- %
R.swd = psr_computeRfromQ(Q.swd);    % compute R matrices for SWDs
R.ctrl = psr_computeRfromQ(Q.ctrl);  % compute R matrices for control epochs

% --- Assign each pair a brain structure - brain structure name --- %
if exist("simpName_sorted",'var')
    for ii = 1:size(spikeArray,1)
        iiString = simpName_sorted{ii}; % current row string
        for jj = 1:size(spikeArray,1)
            jjString = simpName_sorted{jj};
            pairString{ii,jj} = sprintf('%s-%s',iiString,jjString);
        end
    end
else
    pairString = []; % return empty if simpName is not given
end

% --- Make the average correlation matrices --- %
rMatSWD= [];
rMatCTRL = [];
for eii = 1:numel(R.swd)
    rMatSWD = cat(3,rMatSWD,R.swd{eii});
end
for eii = 1:numel(R.ctrl)
    rMatCTRL = cat(3,rMatCTRL,R.ctrl{eii});
end

Rmean.swd = mean(rMatSWD,3,'omitmissing');
Rmean.ctrl = mean(rMatCTRL,3,'omitmissing');
diagIDX = logical(eye(size(Rmean.ctrl)));
Rmean.swd(diagIDX) = 0;  % set identity correlations to 0
Rmean.ctrl(diagIDX) = 0; % set identity correlations to 0

Rmean.names = simpName_sorted;


end % function end
