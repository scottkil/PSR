%%
clear all; close all; clc
topDir = '/media/scott2X/PSR_Data/PSR_30_Day1/PSR_30_Day1_Rec2_250125_152426/';
ffn = sprintf('%sanalogData.bin',topDir);
pathToPupilDir = '/media/scott2X/PSR_Data/PSR_18/PupilTracking/';
pathToFile = sprintf('%seyeIM.mat',pathToPupilDir);
plotFlag = 1;
% psr_eyeImagesToMat(pathToPupilDir); % UI to get directory
psr_eyeImagesToMat('/media/scott4X/PSR_Data_Ext/PSR_39_Day2/Pupil1/');
%%
eyeCamInds = psr_makeEyeCamInds(ffn);
pupil = psr_analyzePupil(pathToFile,plotFlag);

%%
% eyeCamInds(end-1:end) = []; 
fs = 30000; % sampling frequency 
ecft = (eyeCamInds-1)*(1/fs); % eye camera frame times
pupil.ft = ecft;
% fd = psr_binLoadData(ffn,1,3000);
saveName = sprintf('%spupil.mat',topDir);
save(saveName,'pupil','-v7.3');
%%
fc = 1 ; % low-frequency cutoff
[b,a] = butter(4, fc/(25/2), 'low');
diam = fillmissing(pupil.diameter,'nearest');
diam = filtfilt(b,a,diam);
eyeMovement = sum(abs(diff(pupil.cxy,[],1)),2);
eyeMovement = fillmissing(eyeMovement,'nearest',1);
eyeMovement = filtfilt(b,a,eyeMovement);
%% 
figure;
sax(1)= subplot(311);
plot(fd.time,fd.data,'k')
% plot(fd.time,EEGfilt,'k');

sax(2) = subplot(312);
% plot(ecft,pupil.diameter);
plot(ecft, diam, 'b');

sax(3) = subplot(313);
plot(ecft(2:end),eyeMovement);

xlabel('Time (s)');

linkaxes(sax,'x');

%%
fd.finalFS = 3000;
% Wn = [4 10] / (fd.finalFS/2); % bandpass
Wn = 100/(fd.finalFS/2);
% 2. Design the Butterworth filter coefficients
% [b, a] = butter(3, Wn, 'bandpass');
[b,a] = butter(3,Wn,'high');
EEGfilt = filtfilt(b,a,fd.data);