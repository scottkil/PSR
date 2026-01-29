function mpwc = psr_meanPWC(PWC)
%% psr_meanPWC Computes mean pairwise correlations across structure-structure pairs
%
% INPUTS:
%   PWC - a structure with the following fields (output of psr_computePWcorrs):
%             swd:  pairwise correlations during SWD
%             ctrl:  pairwise correlations during nonSWD (control) epochs
%             pairNames: cell array with pairs of brain regions for corresponding correlations in the following format:
%                       BR#1-BR#2 (e.g. 'Caudoputamen-Somatosensory')%
% OUTPUTS:
%   mpwc - a structure with the following fields:               
%             swd:  average pairwise correlation during SWD
%             ctrl: average pairwise correlation during nonSWD (control) epochs
%             names: cell array with pairs of brain regions for corresponding average correlations in the following format:
%             np: number of pairs the averages were taken over
%
% Written by Scott Kilianski
% Updated on 2025-10-01
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% --- Check for pair name flips and combine as needed --- %
[ubps] = unique(PWC.pairNames); % unique brain pairs
for pii = 1:(numel(ubps)-1)
    truePair = ubps{pii};               % get current pair names to inspect
    tmpc = split(truePair,'-');         % split the brain regions
    flippedPair = sprintf('%s-%s',...
        tmpc{2},tmpc{1});               % create the flipped version
    ptfLog = strcmp(flippedPair,PWC.pairNames);
    ptfIDX = find(ptfLog);
    for idxi = 1:numel(ptfIDX)
        PWC.pairNames{ptfIDX(idxi)} = truePair;
    end
end
% ------------------------------------------------------- %

[ubps,~,uIDX] = unique(PWC.pairNames);      % unique brain pairs and indices of those
meanPWC_swd = mean(PWC.swd,1, 'omitnan');   % take means across SWDs
meanPWC_ctrl = mean(PWC.ctrl,1, 'omitnan'); % take means across baseline (ctrl) epochs
for uii = 1:numel(ubps) % for every unique structure pair
    cLog = uIDX == uii; % get the pairs with the current structure pair name
    mpwc.swd(uii,1) = mean(meanPWC_swd(cLog), 'omitnan');   % Calculate mean across matching pairs for SWD
    mpwc.ctrl(uii,1) = mean(meanPWC_ctrl(cLog), 'omitnan'); % Calculate mean across matching pairs for baseline (ctrl) epochs
    mpwc.np(uii,1) = sum(cLog); % number of pairs for current structure-structure pair
end
mpwc.names = ubps;
end % function end