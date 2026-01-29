function [sstend, ctrl_stend] = psr_findsstend(seizures,recSE)
%% psr_findsstend Finding seizure start and end times
%
% INPUTS:
%   seizures - structure with info about seizures
%   recSE - recording start and end times (in seconds)
%
% OUTPUTS:
%   sstend - nx2 matrix with seizure start times in 1st col and end times
%       in 2nd col (in seconds)
%   ctrl_stend - corresponding matrix for nonSWD epochs
%
% Written by Scott Kilianski
% Updated on 2025-09-29
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
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