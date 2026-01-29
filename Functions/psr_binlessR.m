function [blCorrs, pCorrs] = psr_binlessR(Q, timeVec, sigma)
%% psr_binlessR Computes Pearson's correlations coefficients and a 'binless' correlation measure of spikes trains
% See Kruskal et al. (2007) for more info about binless correlations
%   The method in this function is calculated slightly differently than Kruskal et al (2007) but theory is the same
%
% INPUTS:
%   Q - smooth firing rate matrix (in spike/s units). Output from psr_makeQ
%   timeVec - corresponding time (in seconds) of each column in Q. Output from psr_makeQ
%   sigma - in seconds. Sigma determines the width of the Gaussian kernel
%
% OUTPUTS:
%   blCorrs - binless 'correlation' matrix
%   pCorrs - structure Pearson's correlation coefficients
%
% Written by Scott Kilianski
% Updated on 2024-07-17
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
FS = 30000;         % sampling frequency
dsFactor = 30;      % downsampling factor (downsampling to 1000Hz is usually a good idea)
gaussWin = 0.201;   % in sec. Time window over which to evaluate the Gaussian convolution
if ~exist('sigma','var') % default sigma if not specificed as input
    sigma = 0.029;  % in seconds. Sigma determines the width of the Gaussian kernel
end
dsFS = FS/dsFactor; % downsampled sampling frequency

% -- Construct Gaussian kernel for smoothing later -- %
num_points = round(gaussWin*dsFS);  % number of samples
sigmaSamp = sigma*dsFS;             % converting sigma to # of samples
x = linspace(-(num_points-1)/2, (num_points-1)/2, num_points); % generate the range of x values (fixed range)
gaussKern = exp(-0.5 * (x / sigmaSamp).^2); % calculate the Gaussian kernel
gaussKern = gaussKern / sum(gaussKern);     % normalize the kernel
dt = timeVec(2)-timeVec(1); % time step of Q matrix
spkMat = round(Q.*dt)'; % convert Q matrix (firing rate) back to binned spike matrix (spike count units)

% -- Convolve spike trains with Gaussian kernel -- %
fprintf('Convolving spike trains with Gaussian kernel...\n');
numCells = size(Q,1); % # of neurons in this dataset
for k = 1:numCells
    conv_spkMat(:,k) = conv(spkMat(:,k),gaussKern,'same'); % perform convolution with Gaussian kernel
end

% -- Do correlation procedures -- %
fprintf('Calculating correlations...\n');
spkTotMat = repmat(sum(conv_spkMat,1),length(timeVec),1); % spike train matrix (# spikes per timestep)
normEST = conv_spkMat./spkTotMat; % normalized spike train matrix (so each row/neuron total = 1)

% -- Compute correlation measures for each neuron pair -- %
for k = 1:numCells
    for n = 1:numCells
        emptyLog = normEST(:,k) == 0 & normEST(:,n) == 0;           % logical with indices to time steps where both neurons have 0s
        blCorrs(k,n) = trapz(sqrt(normEST(:,k) .* normEST(:,n)));   % take integral of element-wise product of spike trains
        [R,P,RL,RU] = corrcoef(normEST(~emptyLog,k), normEST(~emptyLog,n)); % spike train correlation stats (correlations of time steps when at least 1 neuron is active)
        pCorrs.R(k,n) = R(2);   % correlation r-values
        pCorrs.P(k,n) = P(2);   % corresponding p-values
        pCorrs.RL(k,n) = RL(2); % lower boundary of confidence interval
        pCorrs.RU(k,n) = RU(2); % upper boundary of confidence interval
    end
    fprintf('Neuron %d complete.\n',k);
end

%% Needs update
% indMat = triu(true(size(blCorrs)),1);
% figure;
% subplot(211);
% imagesc(blCorrs);
% clim([0 1]);
% subplot(212);
% histogram(blCorrs(indMat))

end % function end