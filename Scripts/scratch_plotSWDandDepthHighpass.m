%%
topdir = '/media/scott2X/PSR_Data/PSR_31_Day1/PSR_31_Day1_Rec2_250131_124431/';
fname = sprintf('%scombined.bin',topdir);
md = psr_mapBinData(fname,256);

%%
FS = 30000;
aname = sprintf('%sanalogData.bin',topdir);
fd = psr_binLoadData(aname,1,FS);
tsname = sprintf('%stimestamps.bin',topdir);
tsfid = fopen(tsname);
ts = fread(tsfid,'int32');
%%
% --- Design high-pass filter --- %
fc = 300 ; % high-frequency cutoff (Hz)
[b,a] = butter(4, fc/(FS/2), 'high');
% ------------------------------- %
tlim = [214 219]; % seconds
tls = tlim*FS;

tv = double(ts(tls(1):tls(2)))/FS; % convert timestamps to seconds
truncEEG = fd.data(tls(1):tls(2));

truncD = md.Data.ch(:,tls(1):tls(2));
filtD = filtfilt(b, a,double(truncD)')';


%%
% close all
chanList = [95; 23; 13; 64; 60]; % depth-ordered channel list
scaleFactor = 0.195; % to get Intan bits to uV

ampGain = 5000; % amplifier gain (1000, 5000, or 10000 usually)
mvConv = ampGain/1000; % to convert to millivolt (mV scale)
Intan_VoltsToBits = .0003125; 
convF = Intan_VoltsToBits/mvConv; % factor to multiply EEG data by to get mV scale (Intan volts per bit / conversion constant)


for ii = 1:numel(chanList)
    figure;
    cChan = chanList(ii); 
    currD = filtD(cChan,:) * scaleFactor; 
    plot(tv,currD,'k');
    title(cChan-1)
    drawnow
    xlim tight
    ylim([-400 400])
    drawnow
end

figure;
plot(tv,double(truncEEG)*convF,'k');
drawnow
xlim tight
ylim([-3 3])
drawnow