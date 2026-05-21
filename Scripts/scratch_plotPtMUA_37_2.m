%%
load("/media/scott2X/PSR_Data/PSR_35_Day1/PSR_35_Day1_Rec1_250208_183557/meanLayerPtMUA_100msWindow.mat")
xstep = 0.001;
xp = -.05:0.001:.05;
% xp = -0.075:xstep:.075;
% xp = -0.125:xstep:0.125;
halfIdx = ceil(numel(xp)/2);
idx = 1:size(meanLayerPtMUA,2);
clrs = {'b','g','y','r'};
for sii = 1:2
    figure;
    cm = meanLayerPtMUA(:,:,sii);
    cm2 = cm-repmat(min(cm,[],2),1,size(cm,2));
    if any(isnan(cm),'all')
        continue
    else
        for clii = 1:size(cm,1)
            com(clii,sii) = sum(idx .* cm2(clii,:)) / sum(cm2(clii,:)); % center-of-mass
            [~, pkInd(clii,sii)] = max(cm2(clii,:));
            hold on
            plot(xp,cm(clii,:),clrs{clii});
            % xline(xp(pkInd(clii,sii)),clrs{clii});
            xline((com(clii,sii)-halfIdx)*xstep,clrs{clii});
        end
    end
end