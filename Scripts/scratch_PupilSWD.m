%%
szFile = sprintf('%sseizures_EEG.mat',topDir);
pupilFile = sprintf('%spupilData.mat',topDir);
load(szFile,'seizures')
load(pupilFile,'pupil');
sz = seizures;
% --- Get only good seizures --- %
goodLog = strcmp({sz.type},'1') | strcmp({sz.type},'2');
sz(~goodLog) = [];

%%
% --- Loop through seizures and get the peri-seizure pupil data --- %
for zii = 1:numel(sz)
    SEinds = [sz(zii).trTimeInds(1), sz(zii).trTimeInds(end)];
    SEtimes(zii,:) = sz(zii).time(SEinds)'; % starts and ends of seizures
end

% --- Put everything in EEG time --- %
TB = 2; % time buffer (seconds)
TBsz = TB/xDT; % timebuff in samples
xDT = 1/sz(1).parameters{2,5}; % time step of x-query points ("EEG time")

xStart = 0;
xEnd = max(SEtimes(end),pupil.ft(end));
xq = xStart:xDT:xEnd; % x-query points
diam = interp1(pupil.ft,pupil.diam,xq,'linear');
mov = interp1(pupil.ft,pupil.mov,xq,'linear');

%% Get peri-SWD %%
% --- Removing seizures too close to start or end of data streams --- %
rmLog = (SEtimes(:,1) - TB) < pupil.ft(1); % too close to beginning
SEtimes(rmLog,:) = [];
rmLog = (SEtimes(:,2) + TB) > pupil.ft(end); % too close to end
SEtimes(rmLog,:) = [];

nanMat = nan(numel(SEtimes,1),2*TBsz+1);
% Initialize the peri-SWD data structure
pSWD.start_diam = nanMat;
pSWD.end_diam = nanMat;
pSWD.start_mov = nanMat;
pSWD.end_mov = nanMat;
for zii = 1:size(SEtimes,1)
    [~, stIDX] = min(abs(xq-SEtimes(zii,1))); % seizure start index
    [~,endIDX] = min(abs(xq-SEtimes(zii,2))); % seizure end index
    
    stWIN = (stIDX-TBsz):(stIDX+TBsz); % SWD start indices
    endWIN = (endIDX-TBsz):(endIDX+TBsz); % SWD end indices
    pSWD.start_diam(zii,:) = diam(stWIN);
    pSWD.end_diam(zii,:) = diam(endWIN);
    pSWD.start_mov(zii,:) = mov(stWIN);
    pSWD.end_mov(zii,:) = mov(endWIN);
end

%% Plotting %%
tAX = (-TBsz:TBsz)/xDT;
figure;
sax(1) = subplot(221);
psr_plotMeanSTE(sax(1),tAX,pSWD.start_diam,'ste');
hold on
xline(0,'k--');
title('SWD Start Diameter')
sax(2) = subplot(222); 
psr_plotMeanSTE(sax(2),tAX,pSWD.end_diam,'ste');
hold on
xline(0,'k--');
title('SWD End Diameter')
sax(3) = subplot(223); 
psr_plotMeanSTE(sax(3),tAX,pSWD.start_mov,'ste');
hold on
xline(0,'k--');
title('SWD Start Movement')

sax(4) = subplot(224); 
psr_plotMeanSTE(sax(4),tAX,pSWD.end_mov,'ste');
hold on
xline(0,'k--');
title('SWD End Movement')


