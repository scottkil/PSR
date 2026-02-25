%% === Get firing rates during motion, stillness, and seizure === %%
% 2) Count spikes in those times
% 3) Divide by total durations of those 3 categories
topdir = '/media/scott2X/PSR_Data/PSR_07/PSR_07_Rec2_230915_135414/'; % set top-level directory
load(fullfile(topdir,'speed.mat'),'spd'); % load in speed data
seizFile = fullfile(topdir,'seizures_EEG.mat');       % filepath to seizure data 
load(seizFile,'seizures');    % load in seizure data
FS = 30000; % original sampling frequency (almost always 30kHz)
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % find type 1s and 2s
seizures(~keepLog) = []; % remove bad "seizures"

    TSfile = fullfile(topdir,'timestamps.bin');
    tfsID = fopen(TSfile);
    TS = fread(tfsID,Inf,'int32=>double'); % timestamps
    fclose(tfsID);

% -- Find start and end times of seizures -- %
for szi = 1:numel(seizures)
    swdStart = seizures(szi).time(seizures(szi).trTimeInds(1));   % seizure start time
    swdEnd = seizures(szi).time(seizures(szi).trTimeInds(end)); % seizure end time
end

[spikeArray, neuronChans, clustIDs] = psr_makeSpikeArray_TS(fullfile(topdir,'/kilosort4/'));

% 1) Break up recording into motion w/no SWD, stillness w/no SWD, and SWD times
% Every interval in recording is assigned a categorical label:
%   1: SWD
%   2: Moving - no SWD
%   3: Stillness - no SWD
