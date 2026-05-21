function pvals = psr_phase_pvals(szCounts,mv,nPerms)
%% psr_phase_pvals Computes p-values for vector lengths from a null distribution
%
% INPUTS:
%   szCounts - cell array with binned spike matrices of all seizures (output from psr_spikePhase)
%   mv - mean vector structure; output from psr_spikePhasePref
%   nPerms - number of permutatiosn to use for estimating null distribution (10,000 is default)
%
% OUTPUTS:
%   pvals - p-values for vector lengths of all neurons
%
% Written by Scott Kilianski
% Updated on 2026-04-22
%% ------------------------------------------------------------ %
if nargin < 3
    nPerms = 10000; % default number of permutations
end

pvals = nan(size(szCounts{1},1),1); % preallocating
for nii = 1:size(szCounts{1},1) % loop for each neuron
    tic
    fprintf('Finding p-value for neuron %d...\n',nii);
    bigMat = []; % #cycle intervals x #time bins. Each row corresponds to one SW cycle
    for szi = 1:numel(szCounts) % loop over seizures
        bigMat = [bigMat; squeeze(szCounts{szi}(nii,:,:))'];
    end
    nullLength = psr_phaselockPermute(bigMat,nPerms);
    gLog = nullLength >= mv.L(nii);
    pvals(nii) = (1+sum(gLog))/(numel(gLog)+1); % find p-value
    toc
end

end % function end
