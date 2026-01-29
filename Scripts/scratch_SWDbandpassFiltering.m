%%
recn = 34;
% chii = minCh(recn);

chii = 33;
fDir = recfin.Filepath_SharkShark_{recn};
ds_fname = sprintf('%s%s',fDir,'downsampled.mat');
sz_fname = sprintf('%s%s',fDir,'seizures_EEG.mat');
filename = sprintf('%s%s',fDir,'analogData.bin');
EEG = psr_binLoadData(filename,1,1000);

load(sz_fname,'seizures');
load(ds_fname,'ds');
tv = ((1:length(ds.data))-1)/ds.fs;
% tv = EEG.time;

% %% === Get all SWD trough times === %%
% periTW = 0.050; % peri-trough time window
% 
% % --- Remove bad seizures --- %
% goodLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
% sz = seizures(goodLog); % keep only good seizures
% TT = [];
% for zii = 1:numel(sz)
%     ctt = sz(zii).time(sz(zii).trTimeInds);
%     TT = [TT; ctt(:)]; % Append current trough times to the total list
% end
% 
% % WATCH OUT FOR EDGE EFFECTS %
% preTT = TT-periTW/2;
% postTT = TT+periTW/2;
% dt = 1/ds.fs;
% for tii = 1:numel(TT)
%     TTmat(tii,:) = preTT(tii):dt:postTT(tii);
% end
% interpTT = interp1(tv,tv,TTmat,'nearest','extrap');
% [~, idx] = ismember(interpTT, tv);

% === Set up filters and coefficients === %%
%%
chii = 177;

lc1 = 100;
hc1 = 200;
fs = ds.fs;
[b1,a1] = butter(4, [lc1 hc1]/(fs/2), 'bandpass');
highcut = 250;
[b2,a2] = butter(4, highcut/(fs/2), 'high');

% === Apply filters and calculate Hilbert transform === %%

chdata = double(ds.data(chii,:))*ds.scaleFactor; % convert units into microvolts
% chdata = EEG.data;
fsig1 = filtfilt(b1, a1, chdata);
env_hilb1 = abs(hilbert(fsig1));        % instantaneous amplitude (envelope)

fsig2 = filtfilt(b2, a2, chdata);
env_hilb2 = abs(hilbert(fsig2));        % instantaneous amplitude (envelope)

% === Plotting === %%
figure
sax(1) = subplot(311);
plot(tv,chdata);
sax(2) = subplot(312);
plot(tv,fsig2);
hold on
plot(tv,env_hilb2);
hold off
title(sprintf('>%dHz',highcut));
sax(3) = subplot(313);
plot(tv,fsig1);
hold on
plot(tv,env_hilb1);
hold off
title(sprintf('%d-%dHz',lc1,hc1));
linkaxes(sax,'x');