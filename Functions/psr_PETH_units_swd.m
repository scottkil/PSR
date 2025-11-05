function [spkPETH, binCen] = psr_PETH_units_swd(topdir,twin)
%% psr_units_esa_swd Generate the mean peri-event time histogram (PETH) for unit spikes during SWDs
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for PETH (in seconds). 0.16 seconds is default
%
% OUTPUTS:
%   spkPETH - 3D matrix with dimensions
%        - Dim1: neurons
%        - Dim2: time points (centered on troughs)
%        - Dim3: SWD troughs
%   binCen - time window vector, corresponds to Dim2 (in seconds)
%
% Written by Scott Kilianski
% Updated on 2025-11-04
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% --- Handle Inputs --- %
if nargin < 2
    twin = 0.16; % default time window if not provided
    plotFlag = 1; % default plotFlag
end
if nargin < 3
    plotFlag = 1; % default plotFlag
end

%% ==== Load and Prep Necessary Data === %%
seizFile = fullfile(topdir,'seizures_EEG.mat'); % load in seizure data
troughTimes = psr_getTroughTimes(seizFile);     % retrieve SWD trough times
ksdir = fullfile(topdir,'kilosort4/');          % kilosort output directory
sa = psr_makeSpikeArray(ksdir);                 % spike time cell array

% --- Make the PETH base window --- %
dt_bin = 0.002;                      % time step for bin vector (0.002 = 2ms)
halfwin = twin/2;                    % half window indices
binEdges = -halfwin:dt_bin:halfwin;  % full window indices
binCen = binEdges(2:end) - dt_bin/2; % window values in seconds units
numNeurons = numel(sa);              % number of neurons in recording

%% === PETH Loop (one for each shank) === %%
for tii = 1:numel(troughTimes) % one iteration per trough
    for nii = 1:numNeurons % one iteration per neuron
        cbe = binEdges + troughTimes(tii);
        spkPETH(nii,:,tii) = histcounts(sa{nii},cbe);
    end % neuron iteration end
end % SWD trough iteration end

end% function end