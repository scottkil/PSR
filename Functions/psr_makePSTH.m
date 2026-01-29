function [startPSTH, endPSTH, timeArray] = psr_makePSTH(seizQ,binSize,buff)
%% psr_makePSTH Makes peri-seizure time histograms for start and end of seizures
%
% INPUTS:
%   seizQ - a cell array of Q matrices, 1 for each seizure
%   binSize - bin size of Q matrices (in seconds)
%   buff - time buffer leading seizure starts and lagging seizure ends
%
% OUTPUTS:
%   startPSTH - binned spike trains around seizure starts
%               D1:cells, D2:time bins, D3: seizure #
%   endPSTH -   binned spike trains around seizure ends
%               D1:cells, D2:time bins, D3: seizure #
%   timeArray - time leading leading to either seizure start or end
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
nbins = (2*buff/binSize+1);
startIDX = 1:nbins;                         % indices to start of all seizQ matrices
timeArray = (startIDX-.5).*binSize-buff;    % approximate seizure-start-relative time (in seconds) of startPSTH bins

% Grab the starts and ends of seizures and store them in matrices
for szi = 1:numel(seizQ)
    nbq = size(seizQ{szi},2);       % number of bins in this specific Q matrix
    endIDX = (nbq-nbins+1):nbq;     % indices to end of all seizures 
    startPSTH(:,:,szi) = seizQ{szi}(:,startIDX);
    endPSTH(:,:,szi) = seizQ{szi}(:,endIDX);
end

end % function end