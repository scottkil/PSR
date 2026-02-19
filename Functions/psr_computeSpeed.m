function spd = psr_computeSpeed(adata,binSize,origFS,smoothWin,moveThresh,plotFlag)
%% psr_computeSpeed Computes speed from rotary encoder data
%
% INPUTS:
%   adata - rotary encoder data (from analog channel)
%   binSize - time bin size (in seconds). 0.25 seconds default
%   origFS - original sampling frequency (in Hz). 30kHz default
%   smoothWin - smoothing window (in seconds). 1 second default
%   moveThresh - movement threshold for finding still periods
%   plotFlag - if 1, then plot. If 0, no plots. 1 is default
%
% OUTPUTS:
%   spd - structure containing the following output variables:
%          time - time vector (in seconds)
%          smoothed - smoothed speed data (cm/s). Same length as time
%          stopTimes - times (in seconds) when the rotary encoder stops 
%          stillTimes - starts and ends of sufficiently long motionless periods
%          stillLog - logical vector storing motionless status. Same length as time
%
% Written by Scott Kilianski
% Updated on 2024-05-08
% ------------------------------------------------------------ %

%% -- Function Body Here -- %%
funClock = tic;

% --- Handle Inputs --- %
if ~exist('binSize','var')
    binSize = 0.25; % default
end
if ~exist('origFS','var')
    origFS = 30000;
end
if ~exist('smoothWin','var')
    smoothWin = 1; % default
end
if ~exist('moveThresh','var')
    moveThresh = 1; % default 
end
if ~exist('plotFlag','var')
    plotFlag = 1; % default
end

% --- Set thresholds and other static values --- %
FS = origFS;     % sampling frequency of data
longThresh = 1; % time threshold for a motionless epoch to be considered actually motionless (in seconds)
stopThresh = moveThresh; % threshold (cm/s) for finding absolute STOPPING time. If you want a different threshold than moveThresh
smws = round(smoothWin/binSize); % smoothing window size (in samples)

% --- Calculate speed vector --- %
tv = (0:length(adata)-1)/FS;            % generate time vector (in seconds)
[~, rt] = risetime(double(adata),tv);   % find rise time indices
binVec = tv(1):binSize:tv(end);         % bin edges
bv = histcounts(rt,binVec);             % bin edges
bc = binVec(1:end-1) + binSize/2;       % bin centers
distK = 0.9576; % distance constant for Scott's setup: distance per output of rotary encoder (in cm)
% distK = 0.6604;                       % distance constant for Ela's setup (in cm)
spdVec = (bv*distK)/binSize;            % delta_dist/delta_time (cm per second)
spd_smoothed = smoothdata(spdVec,...
    "gaussian",smws);                   % smoothed speed vector 

% --- Find 'starting' and 'stopping' instances --- %
moveLog = spd_smoothed>moveThresh;
startInds = find(diff(moveLog)==1)+1; % indices to movement starting
stopInds = find(diff(moveLog)==-1)+1; % indices to movement ending
if startInds(1)>stopInds(1) % if recording STARTS in movement (i.e. a 'stop' is detected first), set the very first sample as 'start' point
    startInds = [1,startInds];
    firstStopFlag = 0;
else 
    firstStopFlag = 1; % indicates that recording starts in stillness
end

if startInds(end)>stopInds(end) % if recording ends in movement, add the final sample as the final stopping point
    stopInds(end+1) = numel(moveLog); 
    endStopFlag = 0;
else
    endStopFlag = 1; % indicates that recording ends in stillness
end

% --- Accounting for situations starting or ending the recording in stillness --- %
stillInds = [stopInds(1:end-1);startInds(2:end)]';      % get start and end indices of the motionless epochs
if firstStopFlag
    stillInds = [1,startInds(1);stillInds]; % sets first interval to 'still'
end
if endStopFlag % 
    stillInds(end+1,:) = [stopInds(end), numel(moveLog)]; % sets very last interval to 'still' 
end

% --- Check if the stopped times are sufficiently long --- %
still_epochs_dur = diff(stillInds,[],2) * binSize;      % calculating durations of motionless epochs
longLog = still_epochs_dur>longThresh;                  % find motionless epochs longer than longThresh
stillInds =stillInds(longLog,:);                        % only keep those epochs that are sufficiently long
stillTimes = [bc(stillInds(:,1))',bc(stillInds(:,2))']; % store start and end TIMES of sufficiently-long stillness
stopTimes = [];     % intialize vector to store precise stop times
stillLog = false(size(spd_smoothed));

% --- Find the precise stopping time of each motionless epoch --- %
for eii = 1:size(stillInds,1)        
    tRange = stillInds(eii,1):stillInds(eii,2);
    [~, tInd] = find(spd_smoothed(tRange)<=stopThresh,1,'first'); % find the moment when the mouse actually STOPS
    stopTimes(eii) = bc(tRange(tInd)); 
    stillLog(tRange) = true;
end

% --- Store data in output structure --- %
spd.stopTimes = stopTimes;
spd.stillTimes = stillTimes;
spd.smoothed = spd_smoothed;
spd.time = bc;
spd.stillLog = stillLog;

%% -- Plot, if plotFlag is on -- %%
if plotFlag
    figure;
    sax(1) = subplot(211);
    plot(bc,spd_smoothed,'k');
    hold on
    scatter(spd.stopTimes,ones(size(spd.stopTimes))*moveThresh,'r*');
    hold off
    title('Speed');
    ylabel('cm/sec');
    xticks([]);

    sax(2) = subplot(212);
    plot(bc,~stillLog,'k');
    ylabel('Moving Status')
    xlabel('Time (sec)')
    linkaxes(sax,'x');
    set(gcf().Children,'FontSize',24, ...
        'FontWeight','Bold')
end

fprintf('Computing speed took %.2f seconds\n',toc(funClock));

end % function end