function pp = psr_propPop(topdir,twin,dt)
%% psr_propPop Calculates the proportion of the population active over time
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for computing proportion of population active.Default is 0.025
%   dt - time step of output vector (in seconds). Default is 0.001 
%
% OUTPUTS:
%   pp - a struction with the following fields:
%       -vals: proportion of population vector over time. 
%               If an element is 0, no neurons fired during twin
%               If an element is 1, all neurons fired AT LEAST 1 SPIKE during twin
%       -time: time vector, corresponds length(pp.vals). Each value is center of time windows in pp.vals
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
sa = psr_makeSpikeArray(ksdir);                         % get the spike times
seizFile = fullfile(topdir,'seizures_EEG.mat');         % load in seizure data
load(seizFile,'seizures');                              % load in seizure data
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),...
    'Delimiter',',');                                   % read in cell info table

%% === Get good SWDs and find their starts and ends === %%
% --- Find start and end times of good seizures --- %
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % find type 1s and 2s
seizures(~keepLog) = []; % remove bad "seizures"

% -- Find start and end times of seizures -- %
for szi = 1:numel(seizures)
    tlimList(szi,1) = seizures(szi).time(seizures(szi).trTimeInds(1));   % seizure start time
    tlimList(szi,2) = seizures(szi).time(seizures(szi).trTimeInds(end)); % seizure end time
end

%% --- Remove neurons from brain regions with < N neurons --- %%
minN = 5;                           % minimum number of neurons needed for analysis below
cats = categorical(nbr);            % assign brain region to each neuron
brNames = categories(cats);         % get names of all the unique brain regions
tlrLog = countcats(cats)<minN;      % find if any region has <N neurons
tlrNames = brNames(tlrLog);         % get the names of those too-low-count regions
brNames(tlrLog) = [];               % remove those brain regions from the list
tlnLog = ismember(cats,tlrNames);   % find the neurons that below to those regions
sa(tlnLog) = [];               % remove corresponding neurons from the Spike Array
nbr(tlnLog) = [];                   % remove the neuron brain region name

%% --- Calculate population activity --- %%
winSize = round(twin / dt);     % coincindence window (in # bins units)
tStart = 0;                     % start at time = 0
tEnd = max(cellfun(@max,sa));   % use last spike as end time
BE = tStart:dt:tEnd;            % bin edges
BC = BE(2:end)-(dt/2);          % bin centers

% --- Label all bins SWD or not --- %
SWDlabel = false(size(BC));     % initialize SWD bin labels
for szi = 1:size(tlimList,1)
    szLog = BC >= tlimList(szi,1) & BC <= tlimList(szi,2);
    SWDlabel(szLog) = true;
end
% --------------------------------- %


NN = []; % number of neurons per structure
for sti = 1:numel(brNames)   % loop through brain structures
    cLog = strcmp(nbr,brNames(sti)); % indices to neurons in current brain structure/region
    spikeArray = sa(cLog);
    NN = numel(spikeArray); % number of neurons
    NC(sti) = NN; % number of cells

    % -- Assign spikes to time bins -- %
    MS = [];
    for ni = 1:NN
        Q = histcounts(spikeArray{ni},BE); % bin the spikes for each neuron
        MS(ni,:) = movsum(Q, winSize);
    end
    logMat = logical(MS); % convert binned spike matrix to logical (ie did a neuron spike AT ALL in given bin)
    ppVec(sti,:) = sum(logMat,1)/NN; % % population activity?????
    structNames{sti} = brNames{sti};

    % -- Plotting proportion active histograms -- %
    figure;
    DBwidth = 0.1;  % proportion neurons active (e.g. 0 to 0.1, .1 to .2, etc.)
    dBE = 0:DBwidth:1;
    subplot(2,2,2);
    histogram(ppVec(sti,~SWDlabel),dBE, 'Normalization','probability','FaceColor','k');
    title('Interictal')
    subplot(2,2,4);
    histogram(ppVec(sti,SWDlabel),dBE, 'Normalization','probability','FaceColor','r');
    title('Ictal')
    subplot(2,2,[1,3]);
    [PDF, pB] = histcounts(ppVec(sti,~SWDlabel),dBE,'Normalization','cdf');
    [probs_nonic, dpB] = histcounts(ppVec(sti,~SWDlabel),dBE,'Normalization','probability');
    % xsub = 1:(numel(PDF));
    plot(dBE(1:end-1),PDF,'k');
    hold on
    [PDF, pB] = histcounts(ppVec(sti,SWDlabel),dBE,'Normalization','cdf');
    [probs_ic, dpB] = histcounts(ppVec(sti,SWDlabel),dBE,'Normalization','probability');
    plot(dBE(1:end-1),PDF,'r');
    hold off
    title(brNames{sti});
    dpBC = dpB(2:end) - dpB(2)/2;
    bhat_dist(sti) = -log(sum(sqrt(probs_ic.*probs_nonic))); % BHATTACHARYYA DISTANCE
end

%% --- Find Highly Synchronous Events (HSEs) -- %%
% HSEs are events wherein a large proportion of neurons fire within a brief time window
[pkVals, pkIDX, ptVals] = findHSE(ppVec, ptile);

for bi = 1:size(ppVec,1) 
    LOCS = pkIDX{bi};
    PKS = pkVals{bi};

    % -- Plotting -- %
    % figure; plot(BC,ppVec(bi,:),'k');
    % hold on; plot(BC(SWDlabel),ppVec(bi,SWDlabel),'r');
    % scatter(BC(LOCS),PKS,'bo');
    % -------------- %

    HSElog = false(1,size(ppVec,2));
    HSElog(LOCS) = true;            % set 
    HSEi = sum(HSElog & SWDlabel);   % HSEs during itcal times
    HSEni = sum(HSElog & ~SWDlabel); %  HSEs during non-ictal time
    NItime = sum(~SWDlabel) * dt; % total non-ictal time
    Itime = sum(SWDlabel) * dt;   % total ictal time
    fprintf('--------------------\n');
    fprintf('In %s:\n',brNames{bi});
    HSEni_rate = HSEni/NItime;
    HSEi_rate = HSEi/Itime;
    % fprintf('%.3f HSEs per second during non-ictal times\n',HSEni_rate);
    % fprintf('%.3f HSEs per second during ictal times\n',HSEi_rate);
    fprintf('HSE difference: %.3f\n', HSEi_rate-HSEni_rate);
    fprintf('--------------------\n');
    HSE(bi).name = brNames{bi};
    HSE(bi).ni = HSEni_rate;
    HSE(bi).ic = HSEi_rate;
    HSE(bi).nc = NC(bi);
    HSE(bi).bhat_dist = bhat_dist(bi);
end

outName = fullfile(topdir,'analyzedData/','HSE.mat');
save(outName,'HSE','-v7.3');
%% --- Script End --- %%
% fprintf('Script took %.2f seconds to run\n',toc(scriptClock));