function sSWD = psr_speedSWD(topDir)
%% psr_speedSWD Returns speed data relative to SWD times
%
% INPUTS:
%   topDir - top-level data directory
%
% OUTPUTS:
%   sSWD - structure with relevant peri-SWD speed data
%
% Written by Scott Kilianski
% Updated on 2026-02-11
% ------------------------------------------------------------ %
%%
% --- Load the speed data and seizures --- %
TB = 10; % time buffer (seconds)

spdfname = 'speed.mat';
speedFile = sprintf('%s%s',topDir,spdfname);
load(speedFile,'spd');

szFile = sprintf('%sseizures_EEG.mat',topDir);
load(szFile,'seizures')
sz = seizures;

% --- Get only good seizures (type 1 and 2s) --- %
goodLog = strcmp({sz.type},'1') | strcmp({sz.type},'2');
sz(~goodLog) = [];

%%
% --- Loop through seizures and get the peri-seizure speed data --- %
for zii = 1:numel(sz)
    SEinds = [sz(zii).trTimeInds(1), sz(zii).trTimeInds(end)];
    SEtimes(zii,:) = sz(zii).time(SEinds)'; % starts and ends of seizures
end

% --- Put everything in EEG time --- %
xDT = sz(1).parameters{2,5}; % time step of x-query points ("EEG time")
xEnd = max(SEtimes(end),spd.time(end));
xq = 0:xDT:xEnd; % x-query points

% --- If EEG isn't sampled at 200Hz, then resample so it is --- %
if 1/xDT ~= 200
    xDT = 1/200;
    xq = 0:xDT:xEnd; % x-query points
    newSEstarts = interp1(xq,xq,SEtimes(:,1),'nearest');
    newSEends = interp1(xq,xq,SEtimes(:,2),'nearest');
    SEtimes = [newSEstarts,newSEends]; 
end

TBsz = TB/xDT; % timebuff in samples
tAX = (-TBsz:TBsz)*xDT; % corresponding time axis (in seconds)

rs_spd = interp1(spd.time,spd.smoothed,xq,'linear'); % resample speed at x-query points ("EEG time")

% === Get peri-SWD speed data === %
% --- Removing seizures too close to start or end of data streams --- %
rmLog = (SEtimes(:,1) - TB) < spd.time(1); % too close to beginning
SEtimes(rmLog,:) = [];
rmLog = (SEtimes(:,2) + TB) > spd.time(end); % too close to end
SEtimes(rmLog,:) = [];

% --- if either start or end is NaN, remove that seizure from the list --- %
rmLog = sum(isnan(SEtimes),2)>0; 
SEtimes(rmLog,:) = [];

% Initialize the peri-SWD data structure
nanMat = nan(numel(SEtimes,1),2*TBsz+1);
sSWD.start_speed = nanMat;
sSWD.end_speed = nanMat;

sztLog = false(size(spd.time)); % initialize logical indexing vector for speed
stillState_start = false(size(SEtimes,1),1); % logical vector to store if seizure happened while STILL
stillState_end = false(size(SEtimes,1),1); % logical vector to store if subject STILL at the end of SWDs
stopLatency = nan(size(SEtimes,1),1);
for zii = 1:size(SEtimes,1)
    
    [~, stIDX] = min(abs(xq-SEtimes(zii,1))); % seizure start index
    [~,endIDX] = min(abs(xq-SEtimes(zii,2))); % seizure end index
    stWIN = (stIDX-TBsz):(stIDX+TBsz); % SWD start indices
    endWIN = (endIDX-TBsz):(endIDX+TBsz); % SWD end indices
    sSWD.start_speed(zii,:) = rs_spd(stWIN);
    sSWD.end_speed(zii,:) = rs_spd(endWIN);

    csztIDX = spd.time > SEtimes(zii,1) & spd.time < SEtimes(zii,2);
    sztLog(csztIDX) = true; % mark speed times within seizure periods

    % --- Find if SWD started when STILL --- %
    tmpLog = SEtimes(zii,1) >= spd.stillTimes(:,1) & SEtimes(zii,1) <= spd.stillTimes(:,2); 
    stillState_start(zii) = any(tmpLog); % starts

    tmpLog = SEtimes(zii,2) >= spd.stillTimes(:,1) & SEtimes(zii,2) <= spd.stillTimes(:,2); 
    stillState_end(zii) = any(tmpLog); % ends

    if stillState_start(zii) % if seizure happens during stillness, when was closest stop time
        stopDiffs = SEtimes(zii,1) - spd.stopTimes; % time interval between all stop times and current SWD start
        stopLatency(zii) = min(stopDiffs(stopDiffs>=0)); % latency between clostest stop time and SWD start
    end
end

sSWD.SWDspeed = mean(spd.smoothed(sztLog));
sSWD.nonSWDspeed = mean(spd.smoothed(~sztLog));
sSWD.timeAX = tAX;
sSWD.ss_start = stillState_start;
sSWD.ss_end = stillState_end;
sSWD.stopLatency = stopLatency;

end % function end