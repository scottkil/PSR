function goodLog = psr_applyQM(ksdir)
%% psr_applyQM Applies 'good' and 'noise' labels to clusters based on quality metric thresholds 
%
% INPUTS:
%   ksdir - Path to kilosort output directory
%
% OUTPUTS:
%   goodLog - logical vector. length(goodLog) = # of clusters. 1 is 'good'.
%   0 is 'noise'
%
% Also rewrites cluster_group.tsv inside ksdir
%
% Written by Scott Kilianski
% Updated on 2025-09-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
load(fullfile(ksdir,'cluster_metrics.mat'),'clmet'); % loading cluster metrics (output from psr_checkClusters())

% -- Setting Thresholds -- %
PMSthresh = 0.1;            % proportion of spikes missing limit
RPVthresh = 0.01;           % refractory period violation threshold
prThresh = 0.5;             % presence ratio threshold
% FRthresh = 0.1;             % firing rate threshold (spikes/sec)
NSthresh = 500;            % minimum number of spikes
SNRthresh = 5;              % signal-to-noise threshold

% -- Apply Thresholds -- %
goodLog = clmet.PMS < PMSthresh & ...
    clmet.ISIV < RPVthresh & ...
    clmet.PR > prThresh & ...
    clmet.SNR > SNRthresh & ...
    clmet.NS > NSthresh;
labCell = cell(numel(clmet.A),2);
labCell(:,1) = clmet.unitID;
labCell(goodLog,2) = {'good'};
labCell(~goodLog,2) = {'noise'};
clusttab = cell2table(labCell,"VariableNames",{'cluster_id','group'});
writetable(clusttab,fullfile(ksdir,'cluster_group.tsv'),...
    'FileType','text','Delimiter','\t');
fprintf('%d ''good'' units remain after applying quality metric criteria\n',sum(goodLog));

end % function end
