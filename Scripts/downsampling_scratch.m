%%
numChans = 256; % number of channels on the probe used to record
fname = 'Y:\robbieX\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634\combined.bin';
ad = memmapfile(fname,'Format','int16');  % memory map to load data
nSamps = numel(ad.Data)/numChans; % divide number of total samples (across all channels) by number of channels to find number of samples
dsFactor = 300;
tLen = floor(nSamps/dsFactor);

%%
readClock = tic;
fname = 'Y:\robbieX\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634\combined.bin';
FID = fopen(fname);
BtoSkip = 2*256*(dsFactor-1);
N = '256*int16';
dsData = fread(FID,[256 tLen],N,BtoSkip);
fprintf('Reading the file took %.2f seconds\n',toc(readClock));
timeVec = (0:tLen-1)/100;

%%
figure;
sax(1) = subplot(211);
plot(timeVec,dsData(43,:));
sax(2) = subplot(212);
plot(timeVec,dsData(243,:));
linkaxes(sax,'x')

%%
figure;
plot(timeVec,dsData(240,:));