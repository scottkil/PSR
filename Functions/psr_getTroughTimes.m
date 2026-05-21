function [troughTimes, tID] = psr_getTroughTimes(seizFile)
%% psr_getTroughTimes Get the times of all SWD troughs
%
% INPUTS:
%   seizFile - filepath to curated seizures .mat file
%
% OUTPUTS:
%   troughTimes - times (in seconds) of all SWD troughs
%   tID - trough ID (SWD#.trough#
%
% Written by Scott Kilianski
% Updated on 2025-11-03
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% --- Check for pair name flips and combine as needed --- %
load(seizFile,'seizures');
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
seizures(~keepLog) = [];
troughTimes = [];
tID = [];
for szi = 1:length(seizures)
    cidx = seizures(szi).trTimeInds;
    troughTimes = [troughTimes; seizures(szi).time(cidx)]; % Append trough times from current seizure
    for tii = 1:numel(cidx)
        if tii < 10
            ctt = sprintf('%d.0%d',szi,tii);
        else 
            ctt = sprintf('%d.%d',szi,tii);
        end
        tID = [tID; str2double(ctt)]; % Append current trough ID
    end
end
end % function end