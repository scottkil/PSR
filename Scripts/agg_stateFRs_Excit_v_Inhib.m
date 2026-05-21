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
    inhibLog = dtbl.Inhibitory & stLog;
    excitLog = ~dtbl.Inhibitory & stLog;
    FR{bri,2} = [dtbl.SWDFR(excitLog), dtbl.StillFR(excitLog), dtbl.MotionFR(excitLog)]; 
    FR{bri,3} = [dtbl.SWDFR(inhibLog), dtbl.StillFR(inhibLog), dtbl.MotionFR(inhibLog)]; 
    FR{bri,1} = ubrs{bri}; % Store the name of the brain region

    % Log10 transforms of firing rate changes (keeping sign of change intact) %
    % negLog = (dtbl.SWDFR(excitLog) - dtbl.nonSWDFR(excitLog)) < 0 ;
    % tmpV = log10(abs(dtbl.SWDFR(excitLog) - dtbl.nonSWDFR(excitLog)));
    % tmpV(negLog) = tmpV(negLog) * -1; 
    % FRdiffLog{bri,2} = tmpV;
    % 
    %     negLog = (dtbl.SWDFR(inhibLog) - dtbl.nonSWDFR(inhibLog)) < 0 ;
    % tmpV = log10(abs(dtbl.SWDFR(inhibLog) - dtbl.nonSWDFR(inhibLog)));
    % tmpV(negLog) = tmpV(negLog) * -1; 
    % FRdiffLog{bri,3} = tmpV;
    % 
    % FRdiffLog{bri,1} = ubrs{bri};
end

% U = [cellfun(@mean,FR(:,2)),cellfun(@std,FR(:,2)),cellfun(@numel,FR(:,2))]';
% I = [cellfun(@mean,FR(:,3)),cellfun(@std,FR(:,3)),cellfun(@numel,FR(:,3))]';
% 
% Uall = U(:)';
% Iall = I(:)';
% 
% CombinedFRs = [Uall;Iall];

%% Convert FRs to mean, std, and number for ANOVA later
stii = 5;
U = [cellfun(@(X) nanmean(X,1), FR(stii,2),'UniformOutput',false),...
    cellfun(@(X) nanstd(X,1), FR(stii,2),'UniformOutput',false),...
    cellfun(@(X) size(X,1), FR(stii,2),'UniformOutput',false)]';

I = [cellfun(@(X) nanmean(X,1), FR(stii,3),'UniformOutput',false),...
    cellfun(@(X) nanstd(X,1), FR(stii,3),'UniformOutput',false),...
    cellfun(@(X) size(X,1), FR(stii,3),'UniformOutput',false)]';

Combined = [U{1}(1),U{2}(1),U{3},U{1}(2),U{2}(2),U{3},U{1}(3),U{2}(3),U{3};...
    I{1}(1),I{2}(1),I{3},I{1}(2),I{2}(2),I{3},I{1}(3),I{2}(3),I{3}];


