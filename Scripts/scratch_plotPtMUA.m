%%
load("/media/scott4X/PSR_Data_Ext/PSR_37_Day2/PSR_37_Day2_Rec2_250211_120424/meanLayerPtMUA_150msWindow.mat")
xstep = 0.001;
% xp = -.05:0.001:.05;
xp = -0.075:xstep:.075;
% xp = -0.125:xstep:0.125;
halfIdx = ceil(numel(xp)/2);
idx = 1:size(meanLayerPtMUA,2);
clrs = {'b','g','y','r'};
for sii = 1:2
    figure;
    cm = meanLayerPtMUA(:,:,sii);
    com = cm-repmat(min(cm,[],2),1,size(cm,2));
    if any(isnan(cm),'all')
        continue
    else
        for clii = 1:size(cm,1)
            com(clii,sii) = sum(idx .* cm(clii,:)) / sum(cm(clii,:)); % center-of-mass
            [~, pkInd(clii,sii)] = max(cm(clii,:));
            hold on
            plot(xp,cm(clii,:),clrs{clii});
            % xline(xp(pkInd(clii,sii)),clrs{clii});
            xline((com(clii,sii)-halfIdx)*xstep,clrs{clii});
        end
    end
end