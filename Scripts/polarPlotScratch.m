%%
figure;
polaraxes;
hold on
avDeg = linspace(-180,180,100);
% av = linspace(0,2*pi,100);
av = linspace(0,2*pi,101);
for ni = 1:size(szCounts{1},1)
    nism = []; % neuron spike matrix
    for szi = 1:numel(szCounts)
        nism = [nism; squeeze(szCounts{szi}(ni,:,:))'];
    end
    % nismAN(:,:,ni) = nism;
    subplot(5,9,ni);
    nism = circshift(nism,50,2);
    sumVec = sum(nism,1);
    [mV, mI] = max(sumVec);
    prefPhase(ni) = avDeg(mI);
    normVec = sumVec./max(sumVec);
    polarhistogram('BinEdges',av, ...
        'BinCounts',sum(nism,1),'FaceAlpha',1, ...
        'FaceColor','k');
    % polarplot(av,normVec);
end
hold off

histogram(prefPhase,'BinEdges',linspace(-180,180,100));