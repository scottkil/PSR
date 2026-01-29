function [mPETH, fwTime] = psr_PETH_esa_swd(topdir,twin,plotFlag)
%% psr_PETH_esa_swd Generate the mean peri-event time histogram (PETH) for ESA during SWDs
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for PETH (in seconds). 0.16 seconds is default
%   plotFlag - 1 for plotting. 0 for no plots. 1 is default
%
% OUTPUTS:
%   mPETH - cell array with mean z-scored PETHs around SWD troughs. Each element 
%       corresponds to a different shank on the probe. 
%       PETH dimensions are: 
%           - Dim1: channels (depth sorted)
%           - Dim2: time points (centered on troughs)
%           - Dim3: SWD troughs
%   fwTime - time window vector, corresponds to Dim2 of mPETH elements (in seconds)
%
% Written by Scott Kilianski
% Updated on 2025-11-03
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

%% ==== Load Necessary Data === %%
seizFile = fullfile(topdir,'seizures_EEG.mat'); % load in seizure data
troughTimes = psr_getTroughTimes(seizFile);     % retrieve SWD trough times
if plotFlag
    pethFig = figure; % initialize figure
end

%% === PETH Loop (one for each shank) === %%
numShanks = 2; % number of shanks on probe
for shii = 1:numShanks % one iteration per shank
    ESA = psr_getESAvert(topdir,shii); % load in relevant ESA traces
    ESA.mat = zscore(ESA.mat,0,2);         % z-score ESA mat;

    % --- Make the PETH base window --- %
    dt_esa = diff(ESA.time(1:2));        % time step for ESA vector
    twin_samples = round(twin/dt_esa);   % time window (in samples) for PETH
    if mod(twin_samples,2)
        twin_samples = twin_samples + 1; % ensure even number of samples
    end
    halfwin = twin_samples/2; % half window indices
    fwIDX = -halfwin:halfwin; % full window indices
    fwTime = fwIDX*dt_esa;    % window values in seconds units

    % --- troughTimes to find closest index in ESA.time --- %
    interpTT = interp1(ESA.time,ESA.time,troughTimes,'nearest'); % interpolation to ESA time
    [~, TTidx] = ismember(interpTT,ESA.time);                    % get indices to troughs

    % --- Ignore troughs too close to beginning or end of recording --- %
    while TTidx(1)-halfwin < 0
        TTidx(1) = [];   % remove troughs too close to beginning
    end
    while TTidx(end)+halfwin > numel(ESA.time)
        TTidx(end) = []; % remove troughs to close too end
    end
    % ----------------------------------------------------------------------- %

    PETH = []; % initialize PETH matrix
    for tii = 1:numel(interpTT)
        iIDX = TTidx(tii) + fwIDX;
        PETH(:,:,tii) = ESA.mat(:,iIDX);
    end

    if plotFlag
        mPETH{shii} = mean(PETH,3);
        subplot(1,numShanks,shii);
        imagesc(fwTime,1:size(mPETH{shii},1),mPETH{shii});
    end

end

end % function end