function [SilE] = psr_findSilent(pp, SWDlabel,minTimeBtwnPeaks,plotFlag)
%% psr_findSilent Finds silence events, which are events wherein no neurons fire within a brief time window
%
% INPUTS:
%   pp - structure output from psr_propPop
%   SWDlabel - logical vector the same length as pp.time indicating whether time point was during SWD or not
%   minTimeBtwnPeaks - minimum time (in seconds) between peaks in pp.vals so peaks too close in time don't get double counted
%   plotFlag - optional plotting flag. 1 for plots. 0 for no plots. Default is 1
%
% OUTPUTS:
%   SilE - a structure with the following fields:
%     - name: name of brain structure
%     - ni: rate of SilE during nonSWD epochs (events/second)
%     - ic: rate of SilE during SWD (events/second)
%     - nn: number of total neurons in brain structure
%     - diff: difference in rate of SilE between SWD and nonSWD (ic-ni)
%
%
% Written by Scott Kilianski
% Updated on 2026-03-16
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% --- Handle input arguments --- %
if nargin < 3
    minTimeBtwnPeaks = 0.025; % 25 milliseconds
    plotFlag = 1;
elseif nargin < 4
    plotFlag = 1;
end
% ----------------------------- %

% --- Setup time and time binning values --- %
dt = pp.time(2)-pp.time(1);         % time step for propoortion of population vector
mtbpNS = ceil(minTimeBtwnPeaks/dt); % minimum time between peaks in # samples units
% --------------------------------------------------------------------------------------- %

%% === Main Loop, one iteration per brain structure (numel(pp.sn)) === %
% 1) Uses makima interpolation to estimate distribution of proportion of neurons active (psr_estimatePPdist())
% 2) Compute HSE threshold and find HSEs
% 3) Plot CDFs and proportion population vectors
% 4) Calculate HSE rate, etc. and store in output structure

for bii = 1:size(pp.vals,1) % one loop iteration for each brain region


    % ---- 2) Find SilE ---- %
    [PKS,LOCS] = findpeaks(-pp.vals(bii,:),...
        'MinPeakDistance',mtbpNS,...
        'MinPeakHeight',-eps);             % find SilEs 
    % ------------------------------------------------ %


    % ----------- 3) Plotting ----------- %
    if plotFlag

        % ---- Plot proportion population vectors --- %
        figure; plot(pp.time,pp.vals(bii,:),'k','LineWidth',1);
        hold on; 
        h = scatter(pp.time(LOCS),PKS,'bo'); % BE AWARE - doesn't always  display all points because of Matlab 'thinning' on display
    end
    % ---------------------------------------------------------------- %

    % ------- 4) Calculate HSE rate, etc. and store in output structure ------- %
    SilE_log = false(1,size(pp.vals,2));
    SilE_log(LOCS) = true;            % set
    SilE_i = sum(SilE_log & SWDlabel);   % HSEs during itcal times
    SilE_ni = sum(SilE_log & ~SWDlabel); %  HSEs during non-ictal time
    NItime = sum(~SWDlabel) * dt; % total non-ictal time
    Itime = sum(SWDlabel) * dt;   % total ictal time
    fprintf('--------------------\n');
    fprintf('In %s:\n',pp.sn{bii});
    SilE_ni_rate = SilE_ni/NItime;
    SilE_i_rate = SilE_i/Itime;
    fprintf('SilE difference: %.3f\n', SilE_i_rate-SilE_ni_rate);
    fprintf('--------------------\n');
    SilE(bii).name = pp.sn{bii}; % structure name
    SilE(bii).ni = SilE_ni_rate; % HSE baseline (non-ictal) rate
    SilE(bii).ic = SilE_i_rate;  % HSE SWD rate (ictal)
    SilE(bii).nn = pp.nn(bii); % number of neurons per structure
    SilE(bii).diff = SilE_i_rate-SilE_ni_rate; % different between baseline and SWD HSE rate
end
