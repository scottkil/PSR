%%
clear all
% topdir = '/media/scott2X/PSR_Data/PSR_07/PSR_07_Rec2_230915_135414/';
% topdir =  '/media/scott4X/PSR_Data_Ext/PSR_40_Day1/PSR_40_Day1_Rec2_250214_225128/';
topdir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day2/PSR_40_Day2_Rec1_250215_173210/';
seizFile = fullfile(topdir,'seizures_EEG.mat');
load(seizFile,"seizures");

FS = 30000;
binWidth = .01; % seconds

winSize = 0.05;
halfWin = winSize/2;

KSdir = fullfile(topdir,'kilosort4/');
[spikeArray , clustIDs] = psr_makeSpikeArray(KSdir);
tLims(1) = 0;
tLims(2) = max(cellfun(@max,spikeArray));
[Q, timevec] = psr_makeQ(spikeArray,tLims,binWidth,binWidth);
ad = psr_binLoadData(fullfile(topdir,'analogData.bin'),1,3000);

%%
% [binnedSpks, binCenters] = sk_binSpikes(spikeArray,binWidth,startEnd);
zSpkTrains = zscore(Q,0,2);
% pwc = corrcoef(zSpkTrains');

% [coeff,score,latent,tsquared,explained] = pca(zSpkTrains');

% GENERATE PCs FROM ACTIVITY DURING A SUBSET OF SEIZURES
[TT, tID] = psr_getTroughTimes(seizFile);
TTsse = [TT-halfWin,TT+halfWin];
nT = numel(TT);
randSet = 1:nT;
% randSet = randsample(numel(curated_seizures),nSWD);

binTTlog = false(size(timevec)); 
for ttii = 1:2:nT
    durTTlog = timevec >= TTsse(ttii,1) & timevec <= TTsse(ttii,2);
    binTTlog(durTTlog) = true;
end

%%
TTspkTrains = zSpkTrains(:,binTTlog); 
[coeff,score,latent,~,explained] = pca(TTspkTrains',"NumComponents",3);
% [coeff,score,latent,~,explained] = pca(SWDspkTrains',"NumComponents",3);

numTT = numel(TT);
fprintf('# seizures: %d\n',numTT);
projPCA = zSpkTrains'*coeff;

%% explained
figure;
cmap = jet(size(projPCA,1));
% cmap = parula(size(score,1));
% scatter3(score(:,1),score(:,2),score(:,3),[],cmap,"filled");
% scatter3(projPCA(:,1),projPCA(:,2),projPCA(:,3),[],cmap,"filled");

% axis equal
% xlabel('1st Principal Component')
% ylabel('2nd Principal Component')
% zlabel('3rd Principal Component')

% scatter3(timevec,projPCA(:,1),projPCA(:,2),[],cmap,"filled");
% plot3(timevec,projPCA(:,1),projPCA(:,2));
sax(1) = subplot(211);
plot(ad.time,ad.data,'k');

sax(2) = subplot(212);
plot(timevec,projPCA(:,1));
% plot(timevec,projPCA(:,2));

xlabel('Time')
ylabel('1st Principal Component')
% zlabel('2nd Principal Component')
hold on
yv = ones(1,numel(TT))*25;
zv = ones(1,numel(TT))*10;
% scatter3(TT,yv,zv,'k*');
scatter(TT,zv,'k*');

hold off
linkaxes(sax,'x');
%%
% figure;
% plot3(binCenters,projPCA(:,1),projPCA(:,2),'k');
% 
% % axis equal
% xlabel('Time')
% ylabel('1st Principal Component')
% zlabel('2nd Principal Component')

% for swdi = 1:numSWDtotal
% hold on
% plot3(curated_seizures(swdi).seizureStartTime,10,10,'k*');
% end
% hold off