function MUA = psr_MUAfromRaw(topdir,dsFS,binW)
%% psr_MUAfromRaw Computes vertically ordered MUA on middle channels and saves output
%
% INPUTS:
%   topdir - top-level directory
%   dsFS - desired downsampled sampling frequency (in Hz) (default: 10kHz)
%   binW - bin width (default 0.001 seconds)
%
% OUTPUTS:
%   MUA - structure containing MUA data:
%           - data: cell array with Col1 as shank 1 and Col2 and shank 2. Each cell has MUA over time
%           - time: corresponding time vector for all elements in MUA.data
%           - bad: logical vector storing TRUE for bad channels in the final output
%
% Written by Scott Kilianski
% Updated on 2026-04-21
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    dsFS = 10000; 
    binW = 0.001; 
elseif nargin < 3
    binW = 0.001; 
end

funClock = tic;
fname = fullfile(topdir,'combined.bin');
originalFS = 30000;         % THIS FUNCTION ASSUMES 30kHz original sampling frequency; change as needed
dsFactor = originalFS/dsFS;  % down-sampling factor
numChans = 256; % number of channels on the probe used to record
ad = memmapfile(fname,'Format','int16');  % memory map to load data
nSamps = numel(ad.Data)/numChans; % divide number of total samples (across all channels) by number of channels to find number of samples
tLen = floor(nSamps/dsFactor); % time length (in # samples units)

% --- Read data at downsampled intervals --- %%-
fprintf('Reading original data in...\n');
readClock = tic;
% fname = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\combined.bin';
FID = fopen(fname);
BtoSkip = 2*numChans*(dsFactor-1);
% N = '256*int16';
N = '256*int16=>single';

dsData = fread(FID,[256 tLen],N,BtoSkip);
% N = '256*int16=>int16';
% dsData = fread(FID,[256 tLen],N,BtoSkip);
fprintf('Reading took %.2f seconds\n',toc(readClock));
tvec = ((1:size(dsData,2))-1)/dsFS;

% --- Perform comman average referencing, excluding bad channels --- %
fprintf('Finding bad channels...\n')
chan_std = std(dsData, 0, 2);
low_thresh  = prctile(chan_std, 5); % finding 'dead' channels
high_thresh = prctile(chan_std, 95); % finding 'noisy' channels

bad_amp = chan_std < low_thresh | chan_std > high_thresh;
global_mean = mean(dsData, 1);

fprintf('Computing correlations to global mean...\n')
r = zeros(size(dsData,1),1);
for i = 1:size(dsData,1)
    tic
    r(i) = corr(dsData(i,:)', global_mean');
    toc
end
bad_corr = r < 0.3;   % loose threshold
badCH = bad_amp | bad_corr;
goodCH = ~badCH(1:128);
CAR1 = mean(dsData(goodCH, :), 1); % generate common average from good channels on shank 1
goodCH = ~badCH(129:256); %
CAR2 = mean(dsData(goodCH, :), 1); % generate common average from good channels on shank 1

% --- Load in middle channels from each channel vertically ordered --- %
load("/home/scott/Documents/PSR/Data/MidVertChans.mat",...
    "midVert1","midVert2");
badCHidx = find(badCH); % get 1-indexed channel numbers of all bad channels
fprintf('Removing common average...\n');
for shii = 1:2
    tic
    % --- For each shank, perform shank-specific CAR, and store result in 'shank1/2' -- %
    if shii == 1
        chList = midVert1+1; % +1 because it's originally 0-indexed
        for chii = 1:numel(chList)
            currch = chList(chii);
            shank1(chii,:) = dsData(currch,:) - CAR1;
        end
    elseif shii == 2
        chList = midVert2+1; % +1 because it's originally 0-indexed
        for chii = 1:numel(chList)
            currch = chList(chii);
            shank2(chii,:) = dsData(currch,:) - CAR2;
        end
    end
    badLog(:,shii) = ismember(chList,badCHidx);
    toc
end
clear dsData % to save on memory

% --- High-pass filtering --- %
fprintf('High-pass filtering...\n')
fc = 300;
order = 4;
[b,a] = butter(order, fc/(dsFS/2), 'high');
shank1 = filtfilt(b, a, shank1')';
shank2 = filtfilt(b, a, shank2')';

% --- Bin MUA on each all channels --- %
fprintf('Computing MUA for ')
bE = 0:binW:tvec(end);
for shii = 1:2
    if shii == 1
        fprintf('Shank 1...\n')
        thr = 3*median(abs(shank1)/0.6745,2); % MUA threshold from Quiroga 2004
        for chii = 1:length(thr)
            spkIDX = find(abs(shank1(chii,:))>thr(chii)); % find indices with spikes
            spkTimes{chii,1} = tvec(spkIDX)';
        end
    elseif shii == 2
        fprintf('Shank 2...\n')
        thr = 3*median(abs(shank2)/0.6745,2);% MUA threshold from Quiroga 2004        for chii = 1:length(thr)
        for chii = 1:length(thr)
            spkIDX = find(abs(shank2(chii,:))>thr(chii)); % find indices with spikes
            spkTimes{chii,2} = tvec(spkIDX)';
        end
    end

end

% --- Save output --- %
MUA.bad = badLog;
MUA.data = cellfun(@(X) histcounts(X,bE),spkTimes,'UniformOutput',false);
MUA.time = bE(2:end)-(binW/2); % corresponding time vector
outName = fullfile(topdir,'MUA.mat');
save(outName,"MUA",'-v7.3');

fprintf('MUA function took %.2f minutes\n',toc(funClock)/60)


end % function end