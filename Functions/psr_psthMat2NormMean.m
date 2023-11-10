function normMat = psr_psthMat2NormMean(PSTHmat)
%% psr_psthMat2NormMean Calculate mean and normalize each cell to it's own row maximum
%
% INPUTS:
%   - PSTHmat - peri-event time histogram matrix. Each row is a cell. Each
%               column is a binned spike rate. 3D: is
%               trial/stimulus/seizure #
%
% OUTPUTS:
%   normMat - peri-event time histogram matrix. Each row is still a cell.
%             Each column is a normalized binned spike rate (normalized 
%             to max in that row)
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
avgMat = mean(PSTHmat,3);       % take average across all events/stimuli/trials/etc
rowMax = max(avgMat,[],2);      % get each cell's max value
tmpMat = repmat(rowMax,1,...
    size(avgMat,2));            % used as divisor to normalize avgMat
normMat = avgMat ./ tmpMat;     % normalize to the max value

end % function end