function [stillProp, shiftDist] = psr_shiftSWD_Still(topDir,shiftRange)
%% psr_shiftSWD_Still Returns a distribution of
%
% INPUTS:
%   topDir - top-level data directory
%   shiftRange - 2-element vector with minimum and maximum time shifts (in seconds)
%
% OUTPUTS:
%   stillProp - proportion of seizures that happen during stillness
%   shiftDist - 
%
% Written by Scott Kilianski
% Updated on 2026-02-17
% ------------------------------------------------------------ %
%%
if nargin < 2
shiftRange = [30 600]; % 30 seconds to 10 minutes
end
nPerm = 1e4; % number of shifts to apply (10,000 is default)
RandPerms = shiftRange(1) + diff(shiftRange)*rand(nPerm,1);
% --- Load the speed data and seizures --- %

spdfname = 'speed.mat';
speedFile = sprintf('%s%s',topDir,spdfname);
load(speedFile,'spd');

szFile = sprintf('%sseizures_EEG.mat',topDir);
load(szFile,'seizures')
sz = seizures;

% --- Get only good seizures (type 1 and 2s) --- %
goodLog = strcmp({sz.type},'1') | strcmp({sz.type},'2');
sz(~goodLog) = [];

%%
% --- Loop through seizures and get the peri-seizure speed data --- %
for zii = 1:numel(sz)
    seizStarts(zii) = sz(zii).time(sz(zii).trTimeInds(1)); % seizure start times
end

    tmpLog = seizStarts >= spd.stillTimes(:,1) & seizStarts <= spd.stillTimes(:,2);
    seizStill = sum(tmpLog,1)';
    stillProp = sum(seizStill)/numel(seizStill);


for pii = 1:nPerm
    shift_starts = seizStarts + RandPerms(pii); % apply shift

    % --- Check if any shifts go past end of recording, apply circular shift if needed
    chLog = shift_starts > spd.time(end); % find shifts past end of recording
    shift_starts(chLog) = shift_starts(chLog) - spd.time(end); % apply

    % for zii = 1:numel(sz)
    % --- Find if SWD started when STILL --- %
    tmpLog = shift_starts >= spd.stillTimes(:,1) & shift_starts <= spd.stillTimes(:,2);
    stillState_start(:,pii) = sum(tmpLog,1)';
    % end
end

shiftDist = sum(stillState_start,1)./size(stillState_start,1);

end % function end

