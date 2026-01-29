function SNR = psr_calcSNR(topdir)
%% functionTemplate Template for functions 
%
% INPUTS:
%   topdir - top level data directory. Must already have rms.mat, amplitudes.mat, and cluster_info.tsv files within it
%
% OUTPUTS:
%   SNR - signal-to-noise ratio for all clusters. 1st col is clusterID. 2nd is SNR
%
% Written by Scott Kilianski
% Updated on 2025-09-04
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
load(fullfile(topdir,'rms.mat'),'rms');
load(fullfile(topdir,'amplitudes.mat'),'ampls');
clusterInfo = readcell(fullfile(topdir,'cluster_info.tsv'), ...
    'FileType','text','Delimiter','\t');
chCol = find(strcmp(clusterInfo(1,:),'ch'));
medianRMS = median(rms.vals,2);
medianAmp = cellfun(@median, ampls(:,2));

% === Loop for calculating SNR for each cluster === %
cIDlist = cell2mat(clusterInfo(2:end,1));
loopClock = tic;
for ci = 1:numel(cIDlist)
    cID = cIDlist(ci);                              % current cluster ID
    cRow = find(cellfun(@(X) isequal(X,cID),...
        clusterInfo(:,1)));                         % find matching row in Cluster Info table
    bestChan = clusterInfo{cRow,chCol};             % find the current cluster's best channel (highest amplitude)
    bestChan = bestChan + 1;                        % convert from 0-indexed to 1-indexed
    SNR(ci,1) = cID;
    SNR(ci,2) = medianAmp(ci)/medianRMS(bestChan);
end


save(fullfile(topdir,'snr.mat','SNR','-v7.3'));


end % function end