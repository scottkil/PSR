function [normIppDist,xp, hf] = psr_estimatePPdist(ppvals,gridN)
%% psr_estimatePPdist Estimates distribution of proportion of population of neurons activated in given time window
%
% INPUTS:
%   ppvals - proportion of population vector --> pp.vals output from psr_propPop
%   gridN - number of grid points to evaluate over the interval: 0 to 1. Default is 500
%
% OUTPUTS:
%   normIppDist - estimated probability distribution of proportion neurons active in a given time window
%   xp - corresponding x-values from 0 to 1 for that distribution
%   hf - handle to figure with estimated distribution
%
% Written by Scott Kilianski
% Updated on 2025-11-06
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
if nargin < 2; gridN = 500; end     % number of grid points default
xp = linspace(0, 1, gridN+1);       % bin edges for histcounts
hc = histcounts(ppvals,xp,...
    'Normalization','probability'); % do histogram binning
lowerEdges = xp(1:end-1);           %
hcIDX  = find(hc~=0);               % indices to bin where counts are not 0. Using these points for interpolation later
propVals = lowerEdges(hcIDX);       % assign the values to the lesser edges of bins
normCounts = hc(hcIDX);             % grab the corresponding probabilities


% --- Assumption: a population proportion of 1 (i.e. all neurons fire in window) is never observed --- %
propVals = [propVals,1]; % add the value of 1 to the end of the possible proportion values vector
normCounts = [normCounts,0]; % assign 0 probability to that value
% ---------------------------------------------------------------------------------------------------- %

ippDist = interp1(propVals,...
    normCounts,xp,"makima",'extrap'); % interpolated population proportion distribution
ippDist(ippDist<0) = 0;               % sometimes makima interpolation overshoots 0. Set those value to 0
normIppDist = ippDist./sum(ippDist);  % normalize the interpolated distribution so it sums to 1

% --- Plotting actual distribution (bars) and interpolated fit (line) --- %
hf = figure;
bar(lowerEdges,hc,3,'k','EdgeColor','none');
hold on
plot(xp,ippDist,'LineWidth',2);
% ----------------------------------------------------------------------- %

end