function [mean_SP, mean_EP, nn, BRs] = psr_MeanPSTHperStructure(topdir, normSP, normEP, timeArray, plotFlag)
%% psr_MeanPSTHperStructure Calculates the PSTH around start and end of SWDs per structure
%
% INPUTS:
%   topdir - path to top-level directory
%   normSP - normalized peri-SWD start time histogram
%   normEP - normalized peri-SWD END time histogram
%   timeArray - time values (relative to t0) corresponding to peri-SWD time histograms (default is just +- integers)
%   plotFlag - 0 for no plotting. 1 for yes plotting (default: 1)
%
% OUTPUTS:
%   mean_SP - mean peri-SWD start histogram
%   mean_EP - mean peri-SWD end histogram
%   nn - number of neurons
%   BRs - brain region names
%
% Written by Scott Kilianski
% Updated on 2026-03-04
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 3
    timeArray = 1:size(normSP,2);
    plotFlag = 1;
elseif nargin < 4
    plotFlag = 1;
end

%%
dtbl = readtable(fullfile(topdir,'CellInfo.csv'),'Delimiter',',');
BRs = unique(dtbl.SimpleName); % just those brain structures

if plotFlag
    figure;
    k = 1;
end

for brii = 1:numel(BRs)  % loop over unique brain structures in the recording
    brLog = strcmp(dtbl.SimpleName,BRs{brii}); % current brain region logical vector
    mean_SP(brii,:) = mean(normSP(brLog,:),1,'omitmissing');
    mean_EP(brii,:) = mean(normEP(brLog,:),1,'omitmissing');
    if plotFlag
        sax(k) = subplot(numel(BRs),2,k);
        psr_plotMeanSTE(sax(k),timeArray,normSP(brLog,:),'std');
        sax(k).Title.String = BRs{brii};
        k = k+1;
        sax(k) = subplot(numel(BRs),2,k);
        psr_plotMeanSTE(sax(k),timeArray,normEP(brLog,:),'std');
        sax(k).Title.String = BRs{brii};
        k = k+1;
    end

    nn(brii) = sum(brLog);
    SN{brii} = BRs{brii};
end


end % function end