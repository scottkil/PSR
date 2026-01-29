function PA = psr_ESA_PAcoupling(szESA,plotFlag)
%% psr_ESA_PAcoupling Calculating phase-amplitude coupling metrics on ESA during seizures
%
% INPUTS:
%   szESA - cell array with ESA vectors of all seizures (output from psr_ESAPhase)
%   plotFlag - 1 for plotting, 0 for no plotting
%
% OUTPUTS:
%   PA.mvl - mean vector length (non-normalized)
%   PA.mvl_norm - mean vector length (normalized [0 min; 1 max])
%   PA.mi - modulation index [0 min; 1 max]
%   PA.preferred_phase - phase where ESA is at its peak
%   PA.P - probability distribution of ESA
%   PA.bin_centers - phase bin centers for the corresponding probability distribution
%
% Learn more about these measures of phase-amplitude coupling from this
% paper: 
%
%   Hülsemann, M. J., Naumann, E., & Rasch, B. (2019). 
%   Quantification of phase-amplitude coupling in neuronal oscillations: 
%   comparison of phase-locking value, mean vector length, modulation index, 
%   and generalized-linear-modeling-cross-frequency-coupling. 
%   Frontiers in neuroscience, 13, 573.
%
% Written by Scott Kilianski
% Updated on 2025-05-13
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
if ~exist('plotFlag','var')
    plotFlag = 1;
end

esaTF = cell2mat(szESA')';            % convert ESA to matrix and transpose 
szESAvec = esaTF(:);                  % linearize it so that all cycles are joined end-to-end
nbins = size(szESA{1},2);             % calculate the # bins per cycle
shiftN = round(nbins/2);              % positions to shift vector so 0degrees is negative peak
repz = size(esaTF,2);                 % calculate how many cycles are in total 
phaseVec = linspace(-pi,pi,nbins)';   % make corresponding phase vector for 1 cycle (-π to π)  
phaseESA = repmat(phaseVec,[repz 1]); % repeat it as many times as there are cycles

%% == Compute MVL == %%
complex_vector = szESAvec .* exp(1i * phaseESA);    % compute complex vector (ESA x phase)
PA.mvl = abs(mean(complex_vector));                 % take the absolute value of the mean to get MVL (mean vector length)
mean_vector = sum(complex_vector) / sum(szESAvec);  % normalized weighted mean
PA.mvl_norm = abs(mean_vector);                     % Normalized strength of phase locking  (0 - none, 1 - max)
PA.preferred_phase = angle(mean_vector);            % in radians, from -π to π

%% == Compute MI == %%
edges = linspace(-pi, pi, nbins + 1);               % edges of phase bins
bin_centers = (edges(1:end-1) + edges(2:end)) / 2;  % centers of phase bins
bin_centers = circshift(bin_centers,shiftN);        % shifting the bin_centers appropriately
amp_per_bin = sum(esaTF,2)';                        % amplitude per phase bin
P = amp_per_bin / sum(amp_per_bin);                 % Normalize to get a probability distribution

% --- Compute Shannon entropy and modulation index --- %
P(P == 0) = eps;            % avoid log(0)
H = -sum(P .* log(P));      % compute total information 
Hmax = log(nbins);          % find maximum possible information
PA.mi = (Hmax - H) / Hmax;  % modulation index (MI)
PA.P = P;                   % store probability distribution (P) in the output structure
PA.bin_centers = bin_centers; % stores bin centers for corresponding P

%% Plotting
if plotFlag
    figure;
    pc = [bin_centers,bin_centers(1)];
    pt = [P,P(1)];
    polarplot(pc,pt,'k',"LineWidth",2);
    rlim([0 0.025])
end

end % function end
