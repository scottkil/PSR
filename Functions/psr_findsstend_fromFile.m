function [sstend, ctrl_stend] = psr_findsstend_fromFile(topdir)
%% psr_findsstend Finding seizure start and end times
%
% INPUTS:
%   topdir - top-level directory
%
% OUTPUTS:
%   sstend - nx2 matrix with seizure start times in 1st col and end times
%       in 2nd col (in seconds)
%   ctrl_stend - corresponding matrix for nonSWD epochs
%
% Written by Scott Kilianski
% Updated on 2026-04-13
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
FS = 30000; % assumes 30kHz sampling rate
% --- Load and handle timestamps --- %
tsFile = fullfile(topdir,'timestamps.bin');  % load timestamps
tsFID = fopen(tsFile);                     % open timestamps file
TS = fread(tsFID,Inf,'int32');             % read in timestamps data
recSE = double([TS(1),TS(end)])./FS;       % recording start and end (in seconds)
fclose(tsFID);                             % close timestamps file

% --- Load in seizures from EEG data --- %
load(fullfile(topdir,'seizures_EEG.mat'),... 
    'seizures');                           % load seizures

goodLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % logical for type 1 or 2 seizures only
seizures(~goodLog) = [];               % remove none type-1 seizures
for szi = 1:numel(seizures)
    sstend(szi,:) = seizures(szi).time(seizures(szi).trTimeInds([1,end])); % first and last troughs (negative peaks)
end

% --- Create control (nonSWD) epoch matrix --- %
ctrl_stend(:,1) = sstend(1:end-1,2);  % start = ends of seizures
ctrl_stend(:,2) = sstend(2:end,1);    % ends = starts of next seizures

% --- Add time before 1st SWD start and after last SWD end --- %
tmpFirst = [recSE(1),sstend(1,1)]; % recording start to start of first seizure
tmpLast = [sstend(end,2), recSE(end)]; % last seizure end to end of recording
ctrl_stend = [tmpFirst; ctrl_stend; tmpLast]; % Append the additional epochs to the ctrl_stend matrix

end % function end