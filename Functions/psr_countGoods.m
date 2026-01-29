function goodNum = psr_countGoods(ksdir)
%% psr_countGoods Counts the number of 'good' labeled clusters in recording
%
% INPUTS:
%   ksdir - kilosort output directory
%
% OUTPUTS:
%   goodNum - Number of 'good' clusters
%
% Written by Scott
% Updated on 2025-09-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
clusttab = readtable(fullfile(ksdir,'cluster_group.tsv'),...
    'FileType','text','Delimiter','\t');
goodNum = sum(strcmp(clusttab.group,'good'));
fprintf('%d ''good'' clusters in this recording\n',goodNum);
end % function end