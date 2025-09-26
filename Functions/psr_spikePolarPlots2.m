function [nismAN, mv, fa] = psr_spikePhasePref(szCounts)
%% psr_spikePhasePref  Calculates phase-locking metrics (vector length and angle) and makes polar plot showing phase of spiking
%
%
% INPUTS:
%   szCounts - cell array with binned spike matrices of all seizures (output from psr_spikePhase)
%   colorList - cell array with colors of plots for each cell
%
% OUTPUTS:
%   nismAN - binned spike matrix for all neurons
%            Dim1: SW cycles
%            Dim2: Time (phase) Bins
%            Dim3: Neuron #
%   mv - mean vector information for each neuron. Structure with following fields:
%       a: mean vector angle (in degrees, 0 to <360)
%       L: normalized vector length (1 is all spikes fall in same phase bin [i.e. perfect phase locking])
%   fa - structure to address the figures produced by this function
%
% Written by Scott Kilianski
% Updated on 2025-09-26
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
ntb = size(szCounts{1},2); % number of time bins
phaseVec = linspace(-pi,pi,ntb)';   % make corresponding phase vector for 1 cycle (-π to π)
ave = linspace(-pi,pi,ntb+1); % angle vector (bin edges) for polar histogram

for ni = 1:size(szCounts{1},1)
    spkmat = []; % initialize neuron (ni) spike count vector

    % -- Transforming the szCounts array into a matrix -- %
    % matrix (spkmat): dim(1) = phase bins; dim(2) = SWD cycle
    for szi = 1:numel(szCounts)
        szi_spm = squeeze(szCounts{szi}(ni,:,:)); % extract spike count matrix for 1 neuron during 1 SWD
        spkmat = [spkmat, szi_spm];               % append to the overall spike count matrix
    end
    spkmat = circshift(spkmat,round(ntb/2),1); % circularly shift the matrix for SWD negative peak (trough) is in the middle
    cmspkvec = sum(spkmat,2);    % cumulative spike count vector (collapsing/counting over SWD cycles)
    totspks = sum(cmspkvec(:));  % total number of spikes in that vector
    norm_sm = cmspkvec./totspks; % normalized spike count vector
    pSWD{}

    % -- Compute Mean Vector Length and Angle (MVL and MVA) -- %
    complex_vector = cmspkvec .* exp(1i * phaseVec); % compute complex vector (cumulative spike count x phase)
    % mvl = abs(mean(complex_vector));                 % take the absolute value of the mean to get MVL (mean vector length)
    mean_vector = sum(complex_vector) / totspks;     % normalized weighted mean
    mv.L(ni) = abs(mean_vector);                     % Normalized strength of phase locking  (0 - none, 1 - max)
    mvac = rad2deg(angle(mean_vector));

    % -- Circularly shift the mean vector angles -- %
    if mvac < 0
        mv.a(ni) = mvac+360;  % transforms negative degrees to positive
    else
        mv.a(ni) = mvac;
    end

    % -- Plotting individual polar plots -- %
    fa(ni) = figure('Visible','on');
    cph = polarhistogram('BinEdges',ave,'BinCounts',norm_sm);
    title(sprintf('Neuron %d',ni));
    set(gcf().Children,'FontSize',14)
    set(gca,'GridAlpha',0.6,'GridColor',[0 0 0])
    set(cph,'FaceAlpha',0.85,'FaceColor',[1.00, 0.50, 0.05],'EdgeAlpha',1,'EdgeColor','none');

    strng = sprintf('Mean Vector Length:  %.2f\n Mean Vector Angle:   %.2f',...
        mv.L(ni),mv.a(ni));
    annotation('textbox', [0.175, 0.7, 0.4, 0.25], ...  % [x y width height] in normalized units
        'String', strng, ...
        'EdgeColor', 'none', ...
        'Color', 'k',...
        'FontSize',18);
    drawnow;
end

end % function end

