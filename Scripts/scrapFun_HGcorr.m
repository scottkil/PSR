function powerR = scrapFun_HGcorr(fDir)
% === Load in recording-level data === %%

% fDir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day2/PSR_40_Day2_Rec1_250215_173210/';
ds_fname = sprintf('%s%s',fDir,'downsampled.mat');
sz_fname = sprintf('%s%s',fDir,'seizures_EEG.mat');
load(sz_fname,'seizures');
load(ds_fname,'ds');
tv = ((1:length(ds.data))-1)/ds.fs;

%% === Get all SWD trough times === %%
periTW = 0.050; % peri-trough time window

% --- Remove bad seizures --- %
goodLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
sz = seizures(goodLog); % keep only good seizures
TT = [];
for zii = 1:numel(sz)
    ctt = sz(zii).time(sz(zii).trTimeInds);
    TT = [TT; ctt(:)]; % Append current trough times to the total list
end

% WATCH OUT FOR EDGE EFFECTS %
preTT = TT-periTW/2;
postTT = TT+periTW/2;
dt = 1/ds.fs;
for tii = 1:numel(TT)
    TTmat(tii,:) = preTT(tii):dt:postTT(tii);
end
interpTT = interp1(tv,tv,TTmat,'nearest','extrap');
[~, idx] = ismember(interpTT, tv);

%% === Set up filters and coefficients === %%

lc1 = 30;
hc1 = 80;
fs = ds.fs;
[b1,a1] = butter(4, [lc1 hc1]/(fs/2), 'bandpass');
highcut = 250;
[b2,a2] = butter(4, highcut/(fs/2), 'high');

% ------ Set up for parallel processing ------ %


%% === Apply filters and calculate Hilbert transform === %%
tic

powerR = zeros(size(ds.data,1),1);
parfor chii = 1:size(ds.data,1)
    chdata = double(ds.data(chii,:))*ds.scaleFactor; % convert units into microvolts
    fsig1 = filtfilt(b1, a1, chdata);
    env_hilb1 = abs(hilbert(fsig1));        % instantaneous amplitude (envelope)

    fsig2 = filtfilt(b2, a2, chdata);
    env_hilb2 = abs(hilbert(fsig2));        % instantaneous amplitude (envelope)

    fastGpower = env_hilb1(idx);
    APpower = env_hilb2(idx);
    tmpFGP = max(fastGpower,[],2);
    tmpAPP = max(APpower,[],2);
    fastGmax(chii,:) = tmpFGP;
    APmax(chii,:) = tmpAPP;
    powerR(chii,:) = corr(tmpFGP,tmpAPP); % Pearson's r for correlation between max AP power and max fast gamma around SWD troughs

end
toc

