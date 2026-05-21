%% Batch SWD and SWC participation rates by brain region
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%% SWC participation rates inhibitory vs. unclassified
for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    swc{bri,1} = ubrs{bri};
    swc{bri,2} = dtbl.SWCPrate_50msWindow(stLog & ~dtbl.Inhibitory);
    swc{bri,3} = dtbl.SWCPrate_50msWindow(stLog & dtbl.Inhibitory);
end

%% SWC participation rates by layer - somatosensory only
% - Top row is cortical layer name
% - 2nd row is unclassified neurons
% - 3rd row is inhibitory neurons
tmpC = dtbl.SWCPrate_50msWindow;
stLog = strcmp(simpName,'Somatosensory');
swcL{1,1} = 2;
swcL{1,2} = 4;
swcL{1,3} = 5;
swcL{1,4} = 6;
swcL{1,5} = 0;

swcL{2,1} = tmpC(stLog & ~dtbl.Inhibitory & (dtbl.CorticalLayer==2));
swcL{2,2} = tmpC(stLog & ~dtbl.Inhibitory & (dtbl.CorticalLayer==4));
swcL{2,3} = tmpC(stLog & ~dtbl.Inhibitory & (dtbl.CorticalLayer==5));
swcL{2,4} = tmpC(stLog & ~dtbl.Inhibitory & (dtbl.CorticalLayer==6));
swcL{2,5} = tmpC(stLog & ~dtbl.Inhibitory & (dtbl.CorticalLayer==0));

swcL{3,1} = tmpC(stLog & dtbl.Inhibitory & (dtbl.CorticalLayer==2));
swcL{3,2} = tmpC(stLog & dtbl.Inhibitory & (dtbl.CorticalLayer==4));
swcL{3,3} = tmpC(stLog & dtbl.Inhibitory & (dtbl.CorticalLayer==5));
swcL{3,4} = tmpC(stLog & dtbl.Inhibitory & (dtbl.CorticalLayer==6));
swcL{3,5} = tmpC(stLog & dtbl.Inhibitory & (dtbl.CorticalLayer==0));
