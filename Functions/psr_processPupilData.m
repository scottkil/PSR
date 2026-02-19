function psr_processPupilData(topDir,lpCut)
%% psr_processPupilData Processes and saves pupil data (used after preprocessing)
%
% INPUTS:
%   topDir - path to top-level directory. Must contain
%   lpCut - lowpass cutoff for filtering data (in Hz)
%
% OUTPUTS:
%   NONE, but saves pupil data into topDir as 'pupil' structure   
%
% Written by Scott Kilianski
% Updated on 2026-02-09
% ------------------------------------------------------------ %
%%
% --- Loading in relevant data --- %
ffn = sprintf('%sanalogData.bin',topDir); % filepath to analog data
pathToDLCout = sprintf('%spupilDLC.csv',topDir);
pupil = psr_analyzeDLCout(pathToDLCout);
eyeCamInds = psr_makeEyeCamInds(ffn);

% --- Find and correct for missing frames --- %
fs = 30000; % sampling frequency 
ecft = (eyeCamInds-1)*(1/fs); % eye camera frame times
missingFrames = numel(ecft) - numel(pupil.rad);
fprintf('%d missing frames\n',missingFrames);
ecft = ecft(1:end-missingFrames); % correct for missing frames BE CAREFUL WITH THIS, IF THERE ARE TOO MANY MISSING FRAMES, DO NOT USE DATA
pupil.ft = ecft;

% --- Remove low-confidence pupil frames --- % 
stdT = 5; % standard deviation threshold
badLVL = median(pupil.mL) - std(pupil.mL) * stdT; % if likelihood levels are too low, then remove
ngLog = pupil.mL < badLVL;  % logical vector of bad values
pupil.rad(ngLog) = nan;     % setting those to NaN
pupil.cxy(ngLog,:) = nan;   % setting those to NaN

% --- Low-pass filter diameter and position data --- %
eyeFS = 1/diff(ecft(1:2));                  % eye imaging sampling frequency (in Hz)
[b,a] = butter(4, lpCut/(eyeFS/2), 'low');  % low pass filter
diam = pupil.rad*2;                         % computing diameter from radii
diam = fillmissing(diam,'nearest');         % fill in missing values
diam = filtfilt(b,a,diam);                  % apply the low pass filter

% eyeMovement = sum(abs(diff(pupil.cxy,[],1)),2);      % calculate movement from position (Pythagorean theorem) 
cxy = fillmissing(pupil.cxy,'nearest',1);
% eyeMovement = fillmissing(eyeMovement,'nearest',1);  % filling in missing values
% eyeMovement = filtfilt(b,a,eyeMovement);             % apply low pass  filter
cxy = filtfilt(b,a,cxy);             % apply low pass  filter
eyeMovement = sum(abs(diff(cxy,[],1)),2);      % calculate movement from position (Pythagorean theorem) 

eyeMovement = [0;eyeMovement] ;                      % make it same length as 'diam'


pupil.diam = diam;          % filtered diameter
pupil.mov = eyeMovement;    % filtered movement
pupil.mf = missingFrames;   % number of missing frames
outName = sprintf('%spupilData.mat',topDir);
save(outName,'pupil','-v7.3');

end % function end