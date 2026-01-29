function seizBinLog = psr_findSeizBins(timeVec,sstend)
%% psr_findSeizBins Finds bins in a time vector during seizures
%
% INPUTS:
%   timeVec - time vector, typically contains center-of-bins time (in seconds)
%   sstend - 2 row matrix with times (in seconds) 
%       1st row is seizure start times. 
%       2nd is seizure end times
%
% OUTPUTS:
%   output1 - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
for szi = 1:size(sstend,1)
    inLog(szi,:) = timeVec>sstend(szi,1) & timeVec<sstend(szi,2);
end
seizBinLog = logical(sum(inLog));
end % function end