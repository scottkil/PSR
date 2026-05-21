%% Excitatory vs. Inhibitory, Firing Rates
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

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
    FR{bri,2} = [dtbl.OverallFR(excitLog)];
    FR{bri,3} = [dtbl.OverallFR(inhibLog)];
    FRdiff{bri,2} = dtbl.SWDFR(excitLog) - dtbl.nonSWDFR(excitLog);
    FRdiff{bri,3} = dtbl.SWDFR(inhibLog) - dtbl.nonSWDFR(inhibLog);
    FR{bri,1} = ubrs{bri}; % Store the name of the brain region
    FRdiff{bri,1} = ubrs{bri};

    % Log10 transforms of firing rate changes (keeping sign of change intact) %
    negLog = (dtbl.SWDFR(excitLog) - dtbl.nonSWDFR(excitLog)) < 0 ;
    tmpV = log10(abs(dtbl.SWDFR(excitLog) - dtbl.nonSWDFR(excitLog)));
    tmpV(negLog) = tmpV(negLog) * -1; 
    FRdiffLog{bri,2} = tmpV;

        negLog = (dtbl.SWDFR(inhibLog) - dtbl.nonSWDFR(inhibLog)) < 0 ;
    tmpV = log10(abs(dtbl.SWDFR(inhibLog) - dtbl.nonSWDFR(inhibLog)));
    tmpV(negLog) = tmpV(negLog) * -1; 
    FRdiffLog{bri,3} = tmpV;

    FRdiffLog{bri,1} = ubrs{bri};
end

%%
U = [cellfun(@mean,FR(:,2)),cellfun(@std,FR(:,2)),cellfun(@numel,FR(:,2))]';
I = [cellfun(@mean,FR(:,3)),cellfun(@std,FR(:,3)),cellfun(@numel,FR(:,3))]';

Uall = U(:)';
Iall = I(:)';

CombinedFRs = [Uall;Iall];

%% Convert FRdiffs to mean, std, and number
Udiff = [cellfun(@mean,FRdiff(:,2)),cellfun(@std,FRdiff(:,2)),cellfun(@numel,FRdiff(:,2))]';
Idiff = [cellfun(@mean,FRdiff(:,3)),cellfun(@std,FRdiff(:,3)),cellfun(@numel,FRdiff(:,3))]';

UallDiff = Udiff(:)';
IallDiff = Idiff(:)';

CombinedDiffs = [UallDiff;IallDiff];

%% Convert FRdiffLogs to mean, std, and number
Udiff = [cellfun(@mean,FRdiff(:,2)),cellfun(@std,FRdiff(:,2)),cellfun(@numel,FRdiff(:,2))]';
Idiff = [cellfun(@mean,FRdiff(:,3)),cellfun(@std,FRdiff(:,3)),cellfun(@numel,FRdiff(:,3))]';

UallDiff = Udiff(:)';
IallDiff = Idiff(:)';

CombinedDiffs = [UallDiff;IallDiff];