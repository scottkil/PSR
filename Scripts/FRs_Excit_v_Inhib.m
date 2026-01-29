%% Excitatory vs. Inhibitory, Firing Rates
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');


%%
simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%%
for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    % for clii = 0:6 % cortical layer
    %     clLog = dtbl.CorticalLayer == clii;
    %     dtbl.nonSWDFR
    % end
    inhibLog = dtbl.Inhibitory & stLog;
    excitLog = ~dtbl.Inhibitory & stLog;
    FR{bri,1} = [dtbl.nonSWDFR(excitLog), dtbl.SWDFR(excitLog)];
    FR{bri,2} = [dtbl.nonSWDFR(inhibLog), dtbl.SWDFR(inhibLog)];
    FRdiff{bri,1} = dtbl.SWDFR(excitLog) - dtbl.nonSWDFR(excitLog);
    FRdiff{bri,2} = dtbl.SWDFR(inhibLog) - dtbl.nonSWDFR(inhibLog);

end

%% Grand totals
grandTotalExcit = cell2mat(FRdiff(:,1));
grandTotalInhib = cell2mat(FRdiff(:,2));