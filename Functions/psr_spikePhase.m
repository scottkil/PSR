function [szCounts, MUcounts] = psr_spikePhase(spikeArray,seizures)
%% psr_spikePhase Bins spikes during seizures. 1st bin is start of cycle, last bin is end of cycle
%
% INPUTS:
%   spikeArray - a nx1 cell array where each cell has spike times for one 
%                 neuron (output of psr_makeSpikeArray)
%   seizures - seizures structure (output of findSeizures/curateSeizures)
%
% OUTPUTS:
%   szCounts - nx1 cell array. Each cell is the binned spike count matrix 
%               for a single seizure (#neurons x # time bins x # SW cycles)
%   MUcounts - nx1 cell array. Each cell is the binned and summed spike 
%               count matrix across all neurons (# SW cycles x # time bins)
%
% Written by Scott Kilianski
% Updated on 2024-05-14
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% sstend = psr_findsstend(seizures);
funClock = tic;
fprintf('Finding SW phase of all spikes...\n')
nbins = 100; % phase bins
for szi = 1:numel(seizures)
    sz = seizures(szi); % retrieve current seizure info
    cszs = [];          % intialize current seizure spike count matrix ( x time bins)
    for cyci = 1:numel(sz.trTimeInds)-1
        cycSE = [sz.time(sz.trTimeInds(cyci)),...
            sz.time(sz.trTimeInds(cyci+1))];        % get the current SW cycle start and end times
        binE = linspace(cycSE(1),cycSE(2),nbins+1); % generate bin edges from those start and end times
        for ni = 1:numel(spikeArray)
            cszs(ni,:,cyci) = histcounts(spikeArray{ni},binE); % binned counts
        end
        MUcounts{szi}(cyci,:) = sum(cszs(:,:,cyci),1);
    end
    szCounts{szi} = cszs;
end
fprintf('SW spike phase analysis took %.2f seconds\n',toc(funClock));
end % function end