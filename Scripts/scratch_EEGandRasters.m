%%
clear all; close all; clc
KSdir = fullfile(topdir,'kilosort4/');
spikeArray = psr_makeSpikeArray(KSdir);
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),...
    'Delimiter',',');
simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%% Re order
for bri = 1:numel(ubrs)
    [~,ordI] = sortrows(dtbl,{'SimpleName','Inhibitory'},{'descend','descend'});
end
SA = spikeArray(ordI);
inhLog = dtbl.Inhibitory(ordI);

% Plot it
sax(1) = subplot(6,1,1);
psr_plotEEGandSWDs(topdir,sax(1));

clr(1,:) = [255, 63, 85]; % inhibitory
clr(2,:) = [106,85,255]; % unclassified
clr = clr./255; % set to 0 to 1
sax(2) = subplot(6,1,2:6);
hold on
for nii = 1:numel(SA)
    if inhLog(nii) == 1
        cc = clr(1,:);
    else
        cc = clr(2,:);
    end
    yv = ones(numel(SA{nii}),1) * nii;
    xv = SA{nii};
    scatter(xv,yv,36,cc,'|','LineWidth',3);
end

linkaxes(sax,'x');


%%
