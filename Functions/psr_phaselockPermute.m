function nullLength = psr_phaselockPermute(bigMat,nPerms)
%% psr_phaselockPermute Performs permutations on binned spike trains to generate null distribution of vector lengths
%
% INPUTS:
%   bigMat - matrix with numRows=number of SW cycles and numCols=number of phase angle bins
%   nPerms - number of permutations to use for estimating null distribution (10,000 is default)
%
% OUTPUTS:
%   nullLength - vector lengths for permuted binned spike trains
%
% Written by Scott Kilianski
% Updated on 2026-04-22
%% ------------------------------------------------------------ %
if nargin < 2
    nPerms = 10000; % 10,000 random permutations is default
end

nbins = size(bigMat,2);            % number of phase angle bins
phaseVec = linspace(-pi,pi,nbins); % make corresponding phase vector for 1 cycle (-π to π)
totspks = sum(bigMat,"all");       % total number of spikes during these SW cycles
cmpx_uc = exp(1i * phaseVec);   % complex unit circle
nullLength = nan(nPerms, 1); % preallocate nullLength for storing results
parfor pii = 1:nPerms
    % shiftMat = [];      % initialize shifted matrix
    shiftMat = nan(size(bigMat)); % preallocate shifted matrix for efficiency
    shiftQ = randi(size(bigMat,2),size(bigMat,1),1); % generate random number of bins to shift for every SWC cycle
    for cyi = 1:numel(shiftQ)
        shiftMat(cyi,:) = circshift(bigMat(cyi,:),shiftQ(cyi),2); % apply the circular shift 
    end
    complex_vector = sum(shiftMat,1) .* cmpx_uc; % mapping phases to the complex unit circle
    mean_vector = sum(complex_vector) / totspks;            % normalized weighted mean
    nullLength(pii) = abs(mean_vector);                     % estimated null distribution of vector lengths
end

end % function end