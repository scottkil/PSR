function [nismAN, prefPhase] = psr_spikePolarPlots(szCounts)
%% psr_spikePolarPlots  Makes polar plot showing phase of spiking 
% INPUTS:
%   szCounts - cell array with binned spike matrices of all seizures (output from psr_spikePhase)
%
% OUTPUTS:
%   nismAN - binned spike matrix for all neurons
%            Dim1: SW cycles
%            Dim2: Time Bins
%            Dim3: Neuron #
%   prefPhase - preferred phase of spiking for all neurons (in degrees, -180 to +180)
%
% Written by Scott Kilianski
% Updated on 2024-08-15
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
ntb = size(szCounts{1},2); % number of time bins
if mod(ntb,2)
    error(['Number of time bins is odd. It must be even. ' ...
        'Recreate szCounts with even number of time bins'])
end
figure;
polaraxes;
hold on
avDeg = linspace(-180,180,ntb); % angle vector in degrees 
av = linspace(0,2*pi,ntb+1); % angle vector for polar plot
for ni = 1:size(szCounts{1},1)
    nism = []; % neuron spike matrix

    % -- Transforming the szCounts array into a matrix -- %
    for szi = 1:numel(szCounts)
        nism = [nism; squeeze(szCounts{szi}(ni,:,:))'];
    end

    nismAN(:,:,ni) = nism;
    nism = circshift(nism,ntb/2,2); % circular shifting so that start/end of cycle is in the middle
    sumVec = sum(nism,1);
    [mV, mI] = max(sumVec);
    prefPhase(ni) = avDeg(mI);
    normVec = sumVec./max(sumVec);
    polarplot(av,normVec);

    % -- Plotting individual polar plots -- %
    % subplot(X,Y,ni); % NEEDS TO BE UPDATED TO APPROPRIATE SIZE
    % av = linspace(0,2*pi,ntb);
    % polarhistogram('BinEdges',av,'BinCounts',normVec);

end
hold off

% -- Histogram of phase preferences across all neurons -- %
figure; 
histogram(prefPhase,'BinEdges',linspace(-180,180,ntb));

end % function end