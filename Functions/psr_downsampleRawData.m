function ds = psr_downsampleRawData(fname,dsFS)
%% psr_downsampleRawData Downsamples raw data in the combined.bin file and saves as .mat file
%
% INPUTS:
%   fname - full file path to combined.bin
%   dsFS - desired downsampled sampling frequency (in Hz)
%
% OUTPUTS:
%   ds - structure containing downsampled data organized into the following fields:
%           - data: #Chans x #Samples (after downsampling) matrix. Stored in in16 format to reduce file size
%           - scaleFactor: multiply by ds.data to convert to microVolts
%           - fs: downsampled sampling frequency. Use (0:size(ds.data,2)-1)./ds.fs to generate time vector for ds.data (in seconds units)
%
% Written by Scott Kilianski
% Updated on 2024-11-22
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
originalFS = 30000;         % THIS FUNCTION ASSUMES 30kHz original sampling frequency; change as needed
scaleFactor = 0.195;        % factor used to convert amplifier_data unit to microvolts
dataDir = fileparts(fname); % 
dsFactor = originalFS/dsFS;  % 
numChans = 256; % number of channels on the probe used to record
ad = memmapfile(fname,'Format','int16');  % memory map to load data
nSamps = numel(ad.Data)/numChans; % divide number of total samples (across all channels) by number of channels to find number of samples
tLen = floor(nSamps/dsFactor); % time length (in # samples units)

%% -- Read data at downsampled intervals -- %%
readClock = tic;
% fname = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\combined.bin';
FID = fopen(fname);
BtoSkip = 2*numChans*(dsFactor-1);
N = '256*int16';
dsData = fread(FID,[256 tLen],N,BtoSkip);
% N = '256*int16=>int16';
% dsData = fread(FID,[256 tLen],N,BtoSkip);
fprintf('Reading the file took %.2f seconds\n',toc(readClock));

%% -- Store in structure and save output -- %%
ds.data = int16(dsData);
ds.scaleFactor = scaleFactor;
ds.fs = originalFS/dsFactor;
foutName = sprintf('%s%s',dataDir,'/downsampled.mat');
save(foutName,'ds','-v7.3');

end % function end