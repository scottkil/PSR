%% Cortical Layers, Mean Vector statistics
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

%% === Prepare relevant data === %%
simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions
mva = dtbl.MeanVectorAngle_toFCXEEG_;
chLog = mva > 180;
mva(chLog) = mva(chLog)-360; % set mean vector angle to range from -180 to 180
mvl = dtbl.MeanVectorLength_toFCXEEG_; % get the mean vector lengths
%% === Split data into different groups based on cortical layers === %%
for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    for clii = 0:6 % cortical layer
        clLog = dtbl.CorticalLayer == clii;
        totLog = clLog & stLog;
        MVA{bri,clii+1} = mva(totLog);
        MVL{bri,clii+1} = mvl(totLog);
    end
end

%% Grand totals
binE = linspace(-180,180,101);
for bri = 1:size(MVA,1)
    figure;
    hold on
    histogram(MVA{bri,1}, binE, 'FaceColor', 'k','FaceAlpha',0.5,...
        'EdgeColor', 'none','Normalization','probability');
    histogram(MVA{bri,2}, binE, 'FaceColor', 'r','FaceAlpha',0.5,...
        'EdgeColor', 'none','Normalization','probability');
    title(['Mean Vector Angle Distribution for ', ubrs{bri}]);
    xlabel('Mean Vector Angle (degrees)');
    ylabel('Frequency');
    legend('Excitatory', 'Inhibitory');
    hold off;
end