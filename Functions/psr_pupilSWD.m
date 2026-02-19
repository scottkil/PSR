function pSWD = psr_pupilSWD(topDir,zFlag)
%% psr_pupilSWD 
%
% INPUTS:
%   topDir - top-level data directory
%   zFlag - 0 for no z-scoring, 1 for z-scoring
%
% OUTPUTS:
%   pSWD - structure with relevant peri-SWD pupil data
%
% Written by Scott Kilianski
% Updated on 2026-02-17
% ------------------------------------------------------------ %
%%
szFile = sprintf('%sseizures_EEG.mat',topDir);
pupilFile = sprintf('%spupilData.mat',topDir);
load(szFile,'seizures')
load(pupilFile,'pupil');
sz = seizures;
% --- Get only good seizures --- %
goodLog = strcmp({sz.type},'1') | strcmp({sz.type},'2');
sz(~goodLog) = [];
TB = 10; % time buffer (seconds)

%%
% --- Loop through seizures and get the peri-seizure pupil data --- %
for zii = 1:numel(sz)
    SEinds = [sz(zii).trTimeInds(1), sz(zii).trTimeInds(end)];
    SEtimes(zii,:) = sz(zii).time(SEinds)'; % starts and ends of seizures
end

% --- Put everything in EEG time --- %
xDT = sz(1).parameters{2,5}; % time step of x-query points ("EEG time")
xEnd = max(SEtimes(end),pupil.ft(end));
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

if zFlag
    zdiam = zscore(pupil.diam); % z-score pupil diameter
    zmov = zscore(pupil.mov); % z-score pupil movement
else
    zdiam = pupil.diam;
    zmov = pupil.mov;
end
% reg_diam = interp1(pupil.ft,pupil.diam,xq,'linear'); % non-z-scored
diam = interp1(pupil.ft,zdiam,xq,'linear');
% mov = interp1(pupil.ft,pupil.mov,xq,'linear'); % non-z-scored
mov = interp1(pupil.ft,zmov,xq,'linear');

%% Get peri-SWD %%
% --- Removing seizures too close to start or end of data streams --- %
rmLog = (SEtimes(:,1) - TB) < pupil.ft(1); % too close to beginning
SEtimes(rmLog,:) = [];
rmLog = (SEtimes(:,2) + TB) > pupil.ft(end); % too close to end
SEtimes(rmLog,:) = [];

% --- if either start or end is NaN, remove that seizure from the list --- %
rmLog = sum(isnan(SEtimes),2)>0; 
SEtimes(rmLog,:) = [];

nanMat = nan(numel(SEtimes,1),2*TBsz+1);
% Initialize the peri-SWD data structure
pSWD.start_diam = nanMat;
pSWD.end_diam = nanMat;
pSWD.start_mov = nanMat;
pSWD.end_mov = nanMat;
sztLog = false(size(pupil.ft)); %
for zii = 1:size(SEtimes,1)
    
    [~, stIDX] = min(abs(xq-SEtimes(zii,1))); % seizure start index
    [~,endIDX] = min(abs(xq-SEtimes(zii,2))); % seizure end index
    stWIN = (stIDX-TBsz):(stIDX+TBsz); % SWD start indices
    endWIN = (endIDX-TBsz):(endIDX+TBsz); % SWD end indices
    pSWD.start_diam(zii,:) = diam(stWIN);
    pSWD.end_diam(zii,:) = diam(endWIN);
    pSWD.start_mov(zii,:) = mov(stWIN);
    pSWD.end_mov(zii,:) = mov(endWIN);
    
    csztIDX = pupil.ft > SEtimes(zii,1) & pupil.ft < SEtimes(zii,2);
    sztLog(csztIDX) = true; % mark pupil frame times within seizure periods
end
pSWD.SWDsize = mean(zdiam(sztLog));
pSWD.nonSWDsiz = mean(zdiam(~sztLog));
pSWD.SWDmov = mean(zmov(sztLog));
pSWD.nonSWDmov = mean(zmov(~sztLog));
pSWD.timeAX = tAX;
pSWD.nz.SWDsize = mean(pupil.diam(sztLog)); % non-z-scored
pSWD.nz.nonSWDsize = mean(pupil.diam(~sztLog)); % non-z-scored
pSWD.nz.SWDmov = mean(pupil.mov(sztLog));
pSWD.nz.nonSWDmov = mean(pupil.mov(~sztLog));

%% Plotting %%
% figure;
% sax(1) = subplot(221);
% psr_plotMeanSTE(sax(1),tAX,pSWD.start_diam,'ste');
% hold on
% xline(0,'k--');
% title('SWD Start Diameter')
% sax(2) = subplot(222); 
% psr_plotMeanSTE(sax(2),tAX,pSWD.end_diam,'ste');
% hold on
% xline(0,'k--');
% title('SWD End Diameter')
% sax(3) = subplot(223); 
% psr_plotMeanSTE(sax(3),tAX,pSWD.start_mov,'ste');
% hold on
% xline(0,'k--');
% title('SWD Start Movement')
% 
% sax(4) = subplot(224); 
% psr_plotMeanSTE(sax(4),tAX,pSWD.end_mov,'ste');
% hold on
% xline(0,'k--');
% title('SWD End Movement')

end % function end


