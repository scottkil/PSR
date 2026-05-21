function mpt = psr_mean_ptESAbyDepth(topdir, shankNum, winSize)
%% psr_mean_ptESAbyDepth Finds the mean peri-trough ESA depth-ordered
%
% INPUTS:
%   topdir - top-level data directory
%   shankNum - shank number. 1 or 2 (1 is more lateral in these recordings). 1 is default
%   winSize - window to look around troughs in seconds. 0.15 is default
%
% OUTPUTS:
%   mpt - a structure with the following fields:
%           mat - depth-ordered mean peri-trough ESA matrix
%           time - corresponding time for that matrix
%           br - depth-ordered brain region labels (same numel as size(mpt.mat,1))
%
% Written by Scott Kilianski
% Updated on 2026-04-15
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    shankNum = 1;
    winSize = 0.15;
elseif nargin < 3
    winSize = 0.15;
end
ESA = psr_getESAvert(topdir,shankNum);
zESA = zscore(ESA.mat,0,2);
% ad = psr_binLoadData(fullfile(topdir,'analogData.bin'),1,3000);

%%
load(fullfile(topdir,'electrodeLocations.mat'),'electrodeLocations')
elIDs = cell2mat(electrodeLocations(:,1));
for chii = 1:numel(ESA.chIDs)
     tmpName = electrodeLocations{elIDs==ESA.chIDs(chii),2};
    if contains(tmpName,'layer 2','IgnoreCase',true)
        newName = '2';
    elseif contains(tmpName,'layer 4','IgnoreCase',true)
        newName = '4';
    elseif contains(tmpName,'layer 5','IgnoreCase',true)
        newName = '5';
    elseif contains (tmpName,'layer 6','IgnoreCase',true)
        newName = '6';
    elseif contains(tmpName,'corpus callosum','IgnoreCase',true)
        newName = 'CC';
    else 
        newName = 'SubC';
    end
     ordBR{chii,1} = newName;
end

%%
% figure;
% sax(1) = subplot(5,1,1);
% plot(ad.time,ad.data,'k');
% 
% sax(2) = subplot(5,1,2:5);
% imagesc(ESA.time,1:size(zESA,1),zESA);
% yticks(1:size(zESA,1))
% yticklabels(ordBR);
% colormap(flipud(gray))
% clim([-5 10])
% 
% linkaxes(sax,'x');

% --- Get trough times --- %
seizFile = fullfile(topdir,'seizures_EEG.mat');
[TT, tID] = psr_getTroughTimes(seizFile);


%%
halfWin = winSize/2;
tstep = diff(ESA.time(1:2));
halfWinSamples = halfWin/tstep;

for ttii = 1:numel(TT)
    [~,idx] = min(abs(TT(ttii) - ESA.time));             % find closest ESA time
    TTsse = [(idx-halfWinSamples):(idx+halfWinSamples)]; % get peri-trough ESA
    ptESAmat(:,:,ttii) = zESA(:,TTsse);
end

%
mpt.time = (-halfWinSamples:halfWinSamples)*tstep;
mpt.mat = mean(ptESAmat,3); % mean peri-trough ESA matrix across all troughs
% figure; contourf(plotTime,1:size(ptESAmat,1),mpt,100,'LineStyle','none');
% set(gca,'YDir','reverse')
% yticks(1:size(zESA,1))
% yticklabels(ordBR);
mpt.br = ordBR; % Assign depth-ordered brain region labels to the output structure

end % function end