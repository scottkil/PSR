function rms = psr_calcRMS(filename,numChans,BLS)
%% psr_calcRMS Calculates Root Mean Square (RMS) for all channels in user-specific bins
%
% INPUTS:
%   filename - full file path to binary data file
%   numChans - number of channels in recording
%   BLS - block length (in seconds). Default is 10
%
% OUTPUTS:
%   rms - structure with following fields:
%       .vals - RMS values (in uV). [#channels x # 10-second bins]
%       .time - corresponding time vector
%
% Written by Scott Kilianski
% Updated on 2025-09-08
% ------------------------------------------------------------ %
% === Handles input and static variables === %
fs = 30000;                   % sampling rate (Hz)
if nargin < 3 || ~exist('BLS','var'); BLS = 10; end% block length (in seconds)

% === Memory Map Data === %
md = psr_mapBinData(filename,numChans); % memory map data
scaleFactor = 0.195; % scale data to microvolts (for Intan data only)


blockLen = BLS * fs;           % samples per 10-sec block
nBlocks = floor(size(md.Data.ch,2) / blockLen);

% === Pick n proporation of blocks to work with (no overlap by construction) === %
n = 1; % proportion of blocks to analyze
nPick = round(n * nBlocks);
% pickIdx = sort(randperm(nBlocks, nPick)); % random blocks
pickIdx = round(linspace(1, nBlocks, nPick)); % evenly spaced blocks
ranges = arrayfun(@(b) ((b-1)*blockLen+1 : b*blockLen), ...
    pickIdx, 'uni', 0); % Convert to sample ranges (cell array of index vectors)


% === Set up filter === %
Fc = 300; % cutoff frequency (Hz)
[b, a] = butter(2, Fc/(fs/2), 'high'); % high-pass Butterworth filter


% === Calculate RMS in various time blocks specific above === %
loopClock = tic;
if canUseGPU
    fprintf('Running on GPU...');
    parfor chki = 1:numel(ranges)
        seg = md.Data.ch(:,ranges{chki}); % get relevant data for current time chunk
        BPdata = filtfilt(b, a, double(seg)'*scaleFactor)';   % band-pass filter data
        avgTrace = mean(BPdata,1); % common average
        BP_Xcar = BPdata-avgTrace; % CAR applied
        rmsVals(:,chki) = sqrt(mean(BP_Xcar.^2, 2)); % root mean square calculation
    end
else
    for chki = 1:numel(ranges)
        seg = md.Data.ch(:,ranges{chki}); % get relevant data for current time chunk
        BPdata = filtfilt(b, a, double(seg)'*scaleFactor)';   % band-pass filter data
        avgTrace = mean(BPdata,1); % common average
        BP_Xcar = BPdata-avgTrace; % CAR applied
        rmsVals(:,chki) = sqrt(mean(BP_Xcar.^2, 2)); % root mean square calculation
        loopRead = toc(loopClock);
        % fprintf('\r%3.2f%% complete, %.2f seconds', chki/numel(ranges)*100,loopRead);

    end
end

fprintf('\nTotal RMS calculation time: %.2f minutes\n',...
    toc(loopClock)/60);              % new line after loop printing
timeVec = cellfun(@mean,ranges)/fs;  % time values for all blocks

% === Organize output and save it === %
rms.vals = rmsVals;
rms.time = timeVec;
datadir = fileparts(filename); 
save(fullfile(datadir,'rms.mat'),'rms','-v7.3');

end % function end

