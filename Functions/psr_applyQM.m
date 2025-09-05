function psr_applyQM(ksdir)
%% psr_applyQM Applies 'good' and 'noise' labels to clusters based on quality metric thresholds 
%
% INPUTS:
%   ksdir - Path to kilosort output directory
%
% OUTPUTS:
%   NONE, just rewrites cluster_group.tsv
%
% Written by Scott Kilianski
% Updated on 2025-09-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
load(fullfile(ksdir,'cluster_metrics.mat'),'clmet'); % loading cluster metrics (output from psr_checkClusters())

% -- Setting Thresholds -- %
cutoffVal = 0.1;           % proportion of spikes missing limit
RPVthresh = 0.01;           % refractory period violation threshold
prThresh = 0.9;             % presence ratio threshold
FRthresh = 0.1;             % firing rate threshold (spikes/sec)
SNRthresh = 5;              % signal-to-noise threshold

% -- Apply Thresholds -- %
goodLog = clmet.PMS < cutoffVal & ...
    clmet.ISIV < RPVthresh & ...
    clmet.PR > prThresh & ...
    clmet.SNR > SNRthresh & ...
    clmet.FR > FRthresh;
labCell = cell(numel(clmet.A),2);
labCell(:,1) = clmet.unitID;
labCell(goodLog,2) = {'good'};
labCell(~goodLog,2) = {'noise'};
clusttab = cell2table(labCell,"VariableNames",{'cluster_id','group'});
writetable(clusttab,fullfile(ksdir,'cluster_group.tsv'),...
    'FileType','text','Delimiter','\t');
fprintf('%d ''good'' units remain after applying quality metric criteria\n',sum(goodLog));

end % function end
