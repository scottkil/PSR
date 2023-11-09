function [sstend] = psr_findsstend(seizures)
%% psr_findsstend Finding seizures start and end times
%
% INPUTS:
%   seizures - structure with info about seizures
%
% OUTPUTS:
%   sstend - nx2 matrix with seizure start times in 1st col and end times
%       in 2nd col (in seconds)
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
t1Log = strcmp({seizures.type},'1'); % logical for type 1 seizures only
seizures(~t1Log) = [];               % remove none type-1 seizures
for szi = 1:numel(seizures)
    sstend(szi,:) = seizures(szi).time(seizures(szi).trTimeInds([1,end]));
end
end % function end