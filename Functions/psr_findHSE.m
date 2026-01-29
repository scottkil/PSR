function [HSE, hf] = psr_findHSE(pp, SWDlabel,ptile,minTimeBtwnPeaks,plotFlag)
%% psr_findHSE Finds HSEs, which are events wherein a large proportion of neurons fire within a brief time window
%
% INPUTS:
%   pp - structure output from psr_propPop
%   SWDlabel - logical vector the same length as pp.time indicating whether time point was during SWD or not
%   ptile - percentile threshold value used for finding HSEs (proportion of 1). Default is 0.95 (95th percentile)
%   minTimeBtwnPeaks - minimum time (in seconds) between peaks in pp.vals so peaks too close in time don't get double counted
%   plotFlag - optional plotting flag. 1 for plots. 0 for no plots. Default is 1
%
% OUTPUTS:
%   HSE - a structure with the following fields:
%     - name: name of brain structure
%     - ni: rate of HSE during nonSWD epochs (events/second)
%     - ic: rate of HSE during SWD (events/second)
%     - nn: number of total neurons in brain structure
%     - diff: difference in rate of HSE between SWD and nonSWD (ic-ni)
%     - SWDcdf: SWD cumulative distribution
%     - basecdf: baseline cumulative distribution 
%     - xp: x-points for CDFs 
%
%   hf - structure to handles of figures from psr_estimatePPdist
%       Dim1: brain region
%       Dim2: baseline vs SWD
%
% Written by Scott Kilianski
% Updated on 2025-11-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% --- Handle input arguments --- %
if nargin < 3
    ptile = 0.95; % default percentile score
    minTimeBtwnPeaks = 0.025; % 25 milliseconds
    plotFlag = 1;
elseif nargin < 4
    minTimeBtwnPeaks = 0.025; % 25 milliseconds
    plotFlag = 1;
elseif nargin < 5
    plotFlag = 1;
end
% ----------------------------- %

% --- Assign values for binning distributions and evaluating kernel density estimates --- %
gridN = 500;                        % evaluation points
dt = pp.time(2)-pp.time(1);         % time step for propoortion of population vector
mtbpNS = ceil(minTimeBtwnPeaks/dt); % minimum time between peaks in # samples units
% --------------------------------------------------------------------------------------- %

%% === Main Loop, one iteration per brain structure (numel(pp.sn)) === %
% 1) Uses makima interpolation to estimate distribution of proportion of neurons active (psr_estimatePPdist())
% 2) Compute HSE threshold and find HSEs
% 3) Plot CDFs and proportion population vectors
% 4) Calculate HSE rate, etc. and store in output structure

for bii = 1:size(pp.vals,1) % one loop iteration for each brain region


    % ---- 1) Interpolate over observed values to estimate true distributions ---- %
    SWDvec = pp.vals(bii,SWDlabel);   % SWD values only
    [SWDdist, xp, hf(bii,2)] = psr_estimatePPdist(SWDvec,gridN); % do the estimation
    baseVec = pp.vals(bii,~SWDlabel); % baseline (nonSWD) values
    [nonSWDdist, xp, hf(bii,1)] = psr_estimatePPdist(baseVec,gridN); % do the estimation
    
    % Generate cumulative distributions %
    SWDcdf = cumsum(SWDdist);
    basecdf = cumsum(nonSWDdist);
    % ---------------------------------------------------------------------------- %

    % ---- 2) Compute HSE Threshold and find HSEs ---- %
    ptidx = find(basecdf>=ptile,1,'first'); % find index of threshold
    ptCut = xp(ptidx);                      % get actual threshold value
    [PKS,LOCS] = findpeaks(pp.vals(bii,:),...
        'MinPeakDistance',mtbpNS,...
        'MinPeakHeight',ptCut);             % find HSEs 
    % ------------------------------------------------ %


    % calculate different between CDFs (metric of how different they are)
    DD = sum(abs(SWDcdf-basecdf))./numel(SWDcdf); % distribution distances

    % ----------- 3) Plotting ----------- %
    if plotFlag
        % ---- Plot cumulative distributions functions --- %
        figure;
        plot(xp,basecdf,'b','LineWidth',2);
        hold on
        plot(xp,SWDcdf,'r','LineWidth',2);
        xline(ptCut,'g--');
        text(.75,.25,sprintf('DD: %.3f',DD));
  
        hold off
        xlim([0 1]);
        ylim([0 1]);

        % ---- Plot proportion population vectors --- %
        figure; plot(pp.time,pp.vals(bii,:),'k');
        hold on; 
        % h = scatter(pp.time(LOCS),PKS,'bo'); % BE AWARE - doesn't always  display all points because of Matlab 'thinning' on display
        yline(ptCut,'g--');
    end
    % ---------------------------------------------------------------- %

    % ------- 4) Calculate HSE rate, etc. and store in output structure ------- %
    HSElog = false(1,size(pp.vals,2));
    HSElog(LOCS) = true;            % set
    HSEi = sum(HSElog & SWDlabel);   % HSEs during itcal times
    HSEni = sum(HSElog & ~SWDlabel); %  HSEs during non-ictal time
    NItime = sum(~SWDlabel) * dt; % total non-ictal time
    Itime = sum(SWDlabel) * dt;   % total ictal time
    fprintf('--------------------\n');
    fprintf('In %s:\n',pp.sn{bii});
    HSEni_rate = HSEni/NItime;
    HSEi_rate = HSEi/Itime;
    fprintf('HSE difference: %.3f\n', HSEi_rate-HSEni_rate);
    fprintf('--------------------\n');
    HSE(bii).name = pp.sn{bii}; % structure name
    HSE(bii).ni = HSEni_rate; % HSE baseline (non-ictal) rate
    HSE(bii).ic = HSEi_rate;  % HSE SWD rate (ictal)
    HSE(bii).nn = pp.nn(bii); % number of neurons per structure
    HSE(bii).diff = HSEi_rate-HSEni_rate; % different between baseline and SWD HSE rate
    HSE(bii).SWDcdf = SWDcdf; % SWD CDF
    HSE(bii).basecdf = basecdf; % baseline CDF
    HSE(bii).distX = xp; % x-points for CDFs
    HSE(bii).DD = DD; % distribution differences
end
