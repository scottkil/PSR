function [prefPhase] = psr_ESAPolarPlots(szESA)
%% psr_ESAPolarPlots  Makes polar plot showing phase of spiking 
% INPUTS:
%   szESA - cell array with ESA phase vectors of all seizures (output from psr_ESAPhase)
%
% OUTPUTS:
%   nismAN - binned spike matrix for all neurons
%            Dim1: SW cycles
%            Dim2: Time Bins
%   prefPhase - preferred phase of spiking for all neurons (in degrees, -180 to +180)
%
% Written by Scott Kilianski
% Updated on 2025-05-12
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
ntb = size(szESA{1}{1},2); % number of time bins
if mod(ntb,2) % DO I STILL NEED THIS BIT???
    error(['Number of time bins is odd. It must be even. ' ...
        'Recreate szCounts with even number of time bins'])
end
figure;
pax = polaraxes;
hold on
% -- SOME WORK NEEDS TO BE DONE HERE. 
%    NEED TO GET THE DEGREE BIN EDGES AND CENTERS RIGHT -- %
avDeg = linspace(-180,180,ntb); % angle vector in degrees 
av = linspace(0,2*pi,ntb); % angle vector for polar plot
ave = linspace(0,2*pi,ntb+1); % angle vector for polar plot

for ni = 1:numel(szESA)
    nism = []; % neuron spike matrix

    % -- Transforming the szCounts array into a matrix -- %
    for szi = 1:numel(szESA{ni})
        % if szi == 45
        %     disp(szi)
        % end
        % if ~isempty(szCounts{szi})
            nism = [nism; szESA{ni}{szi}];
        % else

        % end
    end

    % nismAN(:,:,ni) = nism;
    % nism = circshift(nism,ntb/2,2); % circular shifting so that start/end of cycle is in the middle
    sumVec = sum(nism,1);
    [mV, mI] = max(sumVec);
    prefPhase(ni) = avDeg(mI);
    normVec = sumVec./max(sumVec);
    % axes(pax);
    % polarplot(av,normVec);

    % -- Plotting individual polar plots -- %
    setl = [71:80];
    if any(eq(ni,setl)) % plot the first 10 neurons
        figure; 
            polarplot(av,normVec,'k','LineWidth',2.5);

        % cph = polarhistogram('BinEdges',ave,'BinCounts',normVec);
        title(sprintf('Channel %d',ni));
        set(gcf().Children,'FontSize',14)
        set(gca,'GridAlpha',0.2,'GridColor',[0 0 0])
        % set(cph,'FaceAlpha',1,'FaceColor',[1 0.345 0],'EdgeAlpha',1,'EdgeColor',[1 0.345 0]);
    end

end
hold off

% -- Histogram of phase preferences across all neurons -- %
% figure; 
% histogram(prefPhase,'BinEdges',linspace(-180,180,ntb));
% CIRCULARLY SHIFTING THE PREFERRED PHASE NEEDS TO BE FIXED TOO! % 
negInd = prefPhase<=0;
prefPhase(negInd) = prefPhase(negInd)+360;
prefPhase = prefPhase - 180;
[hc,bie] = histcounts(prefPhase,'BinEdges',linspace(-180, 180,101),'Normalization','probability');
bc = bie(2:end) - abs(diff(bie(1:2))/2);
figure;
bar(bc,hc);
xticks([-135 -90 -45 0 45 90 135])

end % function end