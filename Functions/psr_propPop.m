function pp = psr_propPop(topdir,twin,dt)
%% psr_propPop Calculates the proportion of the population active over time
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for computing proportion of population active.Default is 0.025
%   dt - time step of output vector (in seconds). Default is 0.001
%
% OUTPUTS:
%   pp - a structure with the following fields:
%       -vals: cell array with proportion of population vector over time. Each cell is structure brain region
%               If an element is 0, no neurons fired during twin
%               If an element is 1, all neurons fired AT LEAST 1 SPIKE during twin
%       -time: time vector, corresponds length(pp.vals). Each value is center of time windows in pp.vals
%       -sn: cell array with correspond structure name for each pp.vals
%       -nn: number of neurons in corresponding structure
%
% Written by Scott Kilianski
% Updated on 2025-11-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
funClock = tic; % Function Clock start
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

%% --- Calculate population activity --- %%
winSize = round(twin / dt);     % coincindence window (in # bins units)
tStart = 0;                     % start at time = 0
tEnd = max(cellfun(@max,sa));   % use last spike as end time
BE = tStart:dt:tEnd;            % bin edges
BC = BE(2:end)-(dt/2);          % bin centers

% ---- Main Processing Loop Below ---- %
NN = []; % number of neurons per structure
for sti = 1:numel(brNames)          % loop through brain structures
    cLog = strcmp(simpName,...
        brNames{sti});              % indices to neurons in current brain structure/region
    spikeArray = sa(cLog);          % get spike array restricted only to neurons in current structure/region
    NN(sti,1) = sum(cLog);          % number of neurons in current structure

    % --- Assign spikes to time bins and take moving sum --- %
    tmpCell = cellfun(@(X) histcounts(X,BE),spikeArray,'UniformOutput',false); % binning spikes for each neuron
    Q = cell2mat(tmpCell);          % binned spike matrix
    MS = movsum(Q, winSize, 2);     % take moving sum for each neuron across time
    logMat = logical(MS); % convert binned spike matrix to logical (ie did a neuron spike AT ALL in given bin)
    pp.vals(sti,:) = sum(logMat,1)/NN(sti); % % population activity?????
    pp.sn{sti} = brNames{sti};
end % structure loop end
% ------------------------------------ %
pp.time = BC;
pp.nn = NN;

end % function end

% -- Plotting proportion active histograms -- %
% figure;
% DBwidth = 0.1;  % proportion neurons active (e.g. 0 to 0.1, .1 to .2, etc.)
% dBE = 0:DBwidth:1;
% subplot(2,2,2);
% histogram(ppVec(sti,~SWDlabel),dBE, 'Normalization','probability','FaceColor','k');
% title('Interictal')
% subplot(2,2,4);
% histogram(ppVec(sti,SWDlabel),dBE, 'Normalization','probability','FaceColor','r');
% title('Ictal')
% subplot(2,2,[1,3]);
% [PDF, pB] = histcounts(ppVec(sti,~SWDlabel),dBE,'Normalization','cdf');
% [probs_nonic, dpB] = histcounts(ppVec(sti,~SWDlabel),dBE,'Normalization','probability');
% % xsub = 1:(numel(PDF));
% plot(dBE(1:end-1),PDF,'k');
% hold on
% [PDF, pB] = histcounts(ppVec(sti,SWDlabel),dBE,'Normalization','cdf');
% [probs_ic, dpB] = histcounts(ppVec(sti,SWDlabel),dBE,'Normalization','probability');
% plot(dBE(1:end-1),PDF,'r');
% hold off
% title(brNames{sti});
% dpBC = dpB(2:end) - dpB(2)/2;
% bhat_dist(sti) = -log(sum(sqrt(probs_ic.*probs_nonic))); % BHATTACHARYYA DISTANCE
% end