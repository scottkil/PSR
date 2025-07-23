function output1 = psr_applyQM(ksdir,clmet)
%% psr_applyQM Template for functions 
%
% INPUTS:
%   ksdir - Path to kilosort output directory
%   clmet - cluster metrics (output from psr_checkClusters())
%
% OUTPUTS:
%   NONE, just rewrites cluster_info.tsv and saves previous version
%
% Written by Scott Kilianski
% Updated on 2025-06-09
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%

% -- Setting Thresholds -- %
cutoffVal = 0.15;           % proportion of spikes missing limit
RPVthresh = 0.01;           % refractory period violation threshold
prThresh = 0.9;             % presence ratio threshold
FRthresh = 0.1;             % firing rate threshold (spikes/sec)

% -- Apply Thresholds -- %
goodLog = clmet.PMS < cutoffVal & ...
    clmet.ISIV < RPVthresh & ...
    clmet.PR > prThresh & ...
    clmet.FR > FRthresh;
sum(goodLog)

%%
clmet.unitID;


cgFile = fullfile(ksdir,...
    'cluster_group.tsv');   % cluster group file
clusttab = readtable(cgFile,...
    'FileType','text',...
    'Delimiter', '\t');
clusttab.label = 'good';
clusttab.label = 'noise'; 

% WRITE ORIGINAL CLUSTER LABELS TO DIFFERENT FILNAME %

% RELABEL CLUSTERS GOOD OR NOISE %
% WRITE RELABELED CLUSTERS TO cluster_group.tv %

end % function end