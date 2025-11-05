function psr_PETH_esa_swd()
clear all; clc
shanknum = 2;
topdir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day2/PSR_40_Day2_Rec1_250215_173210/'; 
seizFile = fullfile(topdir,'seizures_EEG.mat');
%%
ESA = psr_getESAvert(topdir,shanknum);
troughTimes = psr_getTroughTimes(seizFile);

%% === Make PETH === %%
% --- Make the PETH base window --- %
twin_seconds = 0.15; % time window around troughs (in seconds)
dt_esa = diff(ESA.time(1:2));
twin_samples = round(twin_seconds/dt_esa);
if mod(twin_samples,2)
    twin_samples = twin_samples + 1; % ensure even number of samples
end
halfwin = twin_samples/2;
fwIDX = -halfwin:halfwin; % full window indices

%%
% --- troughTimes to find closest index in ESA.time --- %
interpTT = interp1(ESA.time,ESA.time,troughTimes,'nearest'); % interpolation
[~, TTidx] = ismember(interpTT,ESA.time);

% --- Ignore troughs too close to beginning or end of recording --- %
while TTidx(1)-halfwin < 0 
    TTidx(1) = []; % remove troughs too close to beginning 
end
while TTidx(end)+halfwin > numel(ESA.time) 
    TTidx(end) = []; % remove troughs to close too end
end
% ----------------------------------------------------------------------- %

for tii = 1:numel(interpTT)
    iIDX = TTidx(tii) + fwIDX;
    PETH(:,:,tii) = ESA.mat(:,iIDX);
end

%%
mPETH = mean(PETH,3);
figure; imagesc(fwIDX,1:size(mPETH,1),mPETH);
%% Plot each PETH %%
% tii = tii+1;
% imagesc(fwIDX,1:44,PETH(:,:,tii)); 