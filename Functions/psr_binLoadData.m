function fd = psr_binLoadData(filename,dch,targetFS)
%% psr_binLoadData Loads and downsamples the data from the analogData.bin data file created by convertRHDtoBIN
%
% INPUTS:
%   filename - full file name to the .bin file (including path). There must
%       also be a timestamps.bin file in the same directory
%   dch - desired data channel. Typical channel mapping:
%                               1-EEG
%                               2-Widefield Camera
%                               3-Rotary Encoder
%                               8-Eye Camera
%   targetFS - desired sampling frequency. This is useful for downsampling data and making it easier to work with
%
% OUTPUTS:
%   fd - a structure with following fields related to the analog signal:
%       data - actual values of data (in 16-bit integer unit)
%       time - times corresponding to values in data field (in seconds)
%       tartgetFS - target sampling frequency specified by user (in samples/second)
%       finalFS - the sampling frequency ultimately used (in
%       samples/second)
%
% Written by Scott Kilianski
% Updated 2024-05-08
% ------------------------------------------------------------ %

%% -- Function Body Below -- %%
funClock = tic; % function clock
% Set defaults as needed if not user-specific by inputs
if ~exist('dch','var')
    dch = 1; % default
end
if ~exist('targetFS','var')
    targetFS = 30000; % default
end

%% -- Data retrieval -- %%
FID = fopen(filename);
ppos = (dch-1) * 2;     % multiply by 2 because there are 2 bytes per value. Starts at 0. 
fseek(FID,ppos,'bof');  % position pointer to first sample of desired trace (e.g. 0)
fprintf('Loading data in\n%s...\n',filename);
data = fread(FID,'int16=>int16',14);
fclose(FID);
samplerate = 30000; % assumes 30kHz sampling rate. NOT ALWAYS TRUE, but usually always true

%% -- Load raw data from .mat and resample -- %%
tsVec = (1:length(data))'-1;                    % create time vector
dsFactor = floor(samplerate / targetFS);        % downsampling factor to achieve targetFS
finalFS = samplerate / dsFactor;                % calculate ultimate sampling frequency to be used
EEGdata = double(data(1:dsFactor:end));         % subsample raw data
EEGtime = tsVec(1:dsFactor:end)/samplerate;     % subsample the time vector at dsFactor
EEGidx = tsVec(1:dsFactor:end)+1;               % indices to EEG times 

%% Create output structure and assign values to fields ---- %%%
fd = struct('data',EEGdata,...
    'time',EEGtime,...
    'finalFS',finalFS,...
    'idx',EEGidx);
fprintf('Loading data took %.2f seconds\n',toc(funClock));

end % function end