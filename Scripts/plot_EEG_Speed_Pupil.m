%%
topdir = '/media/scott2X/PSR_Data/PSR_34_Day2/PSR_34_Day2_Rec1_250208_135034/';
ffn = sprintf('%sanalogData.bin',topdir);
eeg = psr_binLoadData(ffn, 1, 30000); % load analog binary data from channel 1 and 30kHz
load(fullfile(topdir,"speed.mat"),'spd');
load(fullfile(topdir,"pupilData.mat"),'pupil');
load(fullfile(topdir,'seizures_EEG.mat'),'seizures');

sz = seizures;

% --- Get only good seizures (type 1 and 2s) --- %
goodLog = strcmp({sz.type},'1') | strcmp({sz.type},'2');
sz(~goodLog) = [];

% --- Loop through seizures and get the peri-seizure speed data --- %
for zii = 1:numel(sz)
    SEinds = [sz(zii).trTimeInds(1), sz(zii).trTimeInds(end)];
    SEtimes(zii,:) = sz(zii).time(SEinds)'; % starts and ends of seizures
end

%% --- Plotting below --- %
ampGain = 5000; % amplifier gain (1000, 5000, or 10000 usually)
mvConv = ampGain/1000; % to convert to millivolt (mV scale)
Intan_VoltsToBits = .0003125; 
convF = Intan_VoltsToBits/mvConv; % factor to multiply EEG data by to get mV scale (Intan volts per bit / conversion constant)
EEGylim = [-2.3 1]; 
speedYlim = [0 15];
yp = [EEGylim(1),EEGylim(1), EEGylim(2),EEGylim(2)]; % y-points for shading patches
scyp = [speedYlim(1), speedYlim(1), speedYlim(2), speedYlim(2)];
[~,tIDX] = ismember(spd.stopTimes,spd.time);


figure;
dsFactor = 15;
dsIDX = 1:dsFactor:numel(eeg.time);

sax(1) = subplot(411);
hold on
for zii = 1:size(SEtimes,1)
    xp = [SEtimes(zii,1), SEtimes(zii,2), SEtimes(zii,2), SEtimes(zii,1)]; % x-points for shading patches
    patch(xp,yp,'c','EdgeColor','none','FaceAlpha',0.25);
end
plot(eeg.time(dsIDX),double(eeg.data(dsIDX))*convF,'k','LineWidth',2);
hold off
ylim(EEGylim);

sax(2) = subplot(412);
hold on
for sii = 1:(size(spd.stillTimes,1)-1)
    scxp = [spd.stillTimes(sii,2), spd.stillTimes(sii+1,1),...
        spd.stillTimes(sii+1,1), spd.stillTimes(sii,2)]; % x-points for shading patches
    patch(scxp,scyp,'g','EdgeColor','none','FaceAlpha',0.25);
end
plot(spd.time,spd.smoothed,'k','LineWidth',2);
hold off
ylim(speedYlim);

sax(3) = subplot(413);
plot(pupil.ft,pupil.diam,'k','LineWidth',2);
sax(4) = subplot(414);
plot(pupil.ft,pupil.mov,'k','LineWidth',2);
linkaxes(sax,'x');
xlim([800 1100]);