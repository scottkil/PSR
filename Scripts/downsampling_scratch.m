%%
numChans = 256; % number of channels on the probe used to record
fname = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\combined.bin';
ad = memmapfile(fname,'Format','int16');  % memory map to load data
nSamps = numel(ad.Data)/numChans; % divide number of total samples (across all channels) by number of channels to find number of samples
originalFS = 30000;
dsFactor = 300;
tLen = floor(nSamps/dsFactor);

%%
readClock = tic;
fname = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\combined.bin';
FID = fopen(fname);
BtoSkip = 2*256*(dsFactor-1);
N = '256*int16';
dsData = fread(FID,[256 tLen],N,BtoSkip);
% N = '256*int16=>int16';
% dsData = fread(FID,[256 tLen],N,BtoSkip);
fprintf('Reading the file took %.2f seconds\n',toc(readClock));
% timeVec = (0:tLen-1)/100;
tInds = 0:tLen-1;

%%
ds.scaleFactor = scaleFactor;
ds.data = dsDataInt;
ds.tInds = timeVec;
ds.fs = originalFS/dsFactor;