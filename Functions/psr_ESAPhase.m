function [szESA] = psr_ESAPhase(ESA,timevec,seizures)
%% psr_ESAPhase Quantifies ESA across phases of SWD cycles. 1st bin is start of cycle, last bin is end of cycle
%
% INPUTS:
%   ESA - entire spike activity (ESA)
%   seizures - seizures structure (output of findSeizures/curateSeizures)
%
% OUTPUTS:
%   szEsa - nx1 cell array. Each cell is the binned spike count matrix 
%               for a single seizure (#neurons x # time bins x # SW cycles)
%
% Written by Scott Kilianski
% Updated on 2025-05-05
% ------------------------------------------------------------ 

%% ---- Function Body Here ---- %%%
funClock = tic;
fprintf('Finding SW phase of ESA...\n')
nbins = 100; % phase bins
numSZ = numel(seizures);
for szi = 1:numSZ 
    fprintf('Seizure %d of %d phase ...\n',szi,numSZ)
    sz = seizures(szi); % retrieve current seizure info
    pESA = [];          % intialize current seizure ESA phase matrix ( x time bins)
    % if szi == 93
    %     disp(szi);
    % end
    for cyci = 1:numel(sz.trTimeInds)-1
        cycSE = [sz.time(sz.trTimeInds(cyci)),...
            sz.time(sz.trTimeInds(cyci+1))];        % get the current SW cycle start and end times
        ctLog = timevec >= cycSE(1) & timevec() <= cycSE(2); % current time vector logical
        stIDX = find(ctLog,1,'first'); % cycle START index
        endIDX = find(ctLog,1,'last'); % cycle END index
        bint = linspace(timevec(stIDX),timevec(endIDX),nbins);
        pESA(cyci,:) = interp1(timevec(ctLog),ESA(ctLog),bint,'linear');
    end
    szESA{szi} = pESA;
end
fprintf('ESA phase analysis took %.2f seconds\n',toc(funClock));
end % function end