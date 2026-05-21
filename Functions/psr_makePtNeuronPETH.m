function [ptPETH, BC] = psr_makePtNeuronPETH(spikeArray, TT, winsize,tstep)
%% psr_makePtNeuronPETH Makes peri-trough neuron spiking peri-event time histogram (PETH)
%
% INPUTS:
%   spikeArray - cell array with spike times from all neurons (output from psr_makeSpikeArray)
%   TT - trough times (output from psr_getTroughTimes)
%   winsize - full time window around which to look (default is 100ms/0.1 seconds) 
%   tstep - time step between bins (default is 1ms/0.001 seconds)
%
% OUTPUTS:
%   ptPETH - peri-trough time histogram. 3 dimensional matrix where:
%      Dim1: neuron
%      Dim2: time bins (corresponds to `BC` output)
%      Dim3: trough number (average over this to get mean ptPETH)
%   BC - time bin centers corresponding to Dim2 of ptPETH
%
% Written by Scott Kilianski
% Updated on 2026-04-24
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 3
    winsize = 0.1; % default value for winsize
    tstep = 0.001; % default value for tstep
end
if nargin < 4
    tstep = 0.001; % default value for tstep
end
halfwinsz = winsize/2;
binE = -halfwinsz:tstep:halfwinsz;
BC = binE(2:end) - tstep/2;
ptPETH = nan(numel(spikeArray),length(BC));
for ni = 1:numel(spikeArray)
    for ti = 1:numel(TT)
        csa = spikeArray{ni}-TT(ti); % time diff between current trough and neuron spikes
        ptPETH(ni,:,ti) = histcounts(csa,binE);
    end
end

end % function end