function eiVec = psr_EIvec(topdir,twin,dt)
%% psr_EIvec Calculates the E-I (excitatory and inhibitory) sum-of-spikes vector over time
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for computing proportion of population active.Default is 0.025
%   dt - time step of output vector (in seconds). Default is 0.001
%
% OUTPUTS:
%   eiVec - a structure with the following fields:
%       -vals: cell array with sum of spikes over time. Each cell is
%       structure brain region. Row1 is excitatory neurons. Row2 is
%       inhibitory
%       -time: time vector, corresponds length(pp.vals). Each value is center of time windows in pp.vals
%       -sn: cell array with correspond structure name for each pp.vals
%       -nn: number of neurons in corresponding structure
%
% Written by Scott Kilianski
% Updated on 2026-04-06
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% --- Handle Inputs --- %
if nargin < 2
    twin = 0.025;
    dt = 0.001;
elseif nargin < 3
    dt = 0.001;
end

%% --- Load in relevant data --- %%
ksdir = fullfile(topdir,'kilosort4/');                  % path to kilosort output
sa = psr_makeSpikeArray(ksdir);                         % get the spike times                           % load in seizure data
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),...
    'Delimiter',',');                                   % read in cell info table
simpName = dtbl.SimpleName;
brNames = unique(simpName);
inhibLog = dtbl.Inhibitory;

%% --- Calculate population activity --- %%
winSize = round(twin / dt);     % coincindence window (in # bins units)
tStart = 0;                     % start at time = 0
tEnd = max(cellfun(@max,sa));   % use last spike as end time
BE = tStart:dt:tEnd;            % bin edges
BC = BE(2:end)-(dt/2);          % bin centers

% ---- Main Processing Loop Below ---- %
NN = []; % number of neurons per structure
for sti = 1:numel(brNames)          % loop through brain structures
    nLog = strcmp(simpName,...
        brNames{sti});              % indices to neurons in current brain structure/region
    for eii = 1:2                   % loop for excitatory & inhibitory
        switch eii
            case 1
                cLog = nLog & ~inhibLog;
            case 2
                cLog = nLog & inhibLog;
        end
        spikeArray = sa(cLog);          % get spike array restricted only to neurons in current structure/region
        NN(sti,eii) = sum(cLog);        % number of neurons in current structure

        % --- Assign spikes to time bins and take moving sum --- %
        tmpCell = cellfun(@(X) histcounts(X,BE),...
            spikeArray,'UniformOutput',false);          % binning spikes for each neuron
        Q = cell2mat(tmpCell);                          % binned spike matrix
        tmpMUA = movsum(Q, winSize, 2);
        eiVec.vals{sti}(eii,:) = sum(tmpMUA,1); % %take moving sum for all neurons across time
    end
    eiVec.sn{sti} = brNames{sti};                   % structure names
end % structure loop end
% ------------------------------------ %
eiVec.time = BC;
eiVec.nn = NN;

end % function end