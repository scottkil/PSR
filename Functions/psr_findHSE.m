function HSE = psr_findHSE(pp, SWDlabel,minTimeBtwnPeaks)
%% psr_findHSE Finds HSEs, which are events wherein a large proportion of neurons fire within a brief time window
%
% INPUTS:
%   pp - structure output from psr_propPop
%   SWDlabel - logical vector the same length as pp.time indicating whether time point was during SWD or not
%   minTimeBtwnPeaks - minimum time (in seconds) between peaks in pp.vals so peaks too close in time don't get double counted
%%%   ptile - percentile threshold value used for finding HSEs
%
% OUTPUTS:
%   HSE - a structure with the following fields:
%
% Written by Scott Kilianski
% Updated on 2025-11-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
ptThresh = 0.95; 
DBwidth = 0.05;             % distribution bin width. Units:  proportion neurons active (e.g. 0 to 0.1, .1 to .2, etc.)
dBE = 0:DBwidth:1;          % distribution bin edges
BC = dBE(2:end) - DBwidth;  % bin centers
kdXP = 0:0.01:1;            % kerndel density estimate evaluation points
dt = pp.time(2)-pp.time(1); %
mtbpNS = ceil(minTimeBtwnPeaks/dt); % minimum time between peaks in # samples units

for bii = 1:size(pp.vals,1) % one loop iteration for each brain region
    [pks1,loc1] = findpeaks(pp.vals(bii,:),...
        'MinPeakDistance',mtbpNS); %%% First-pass to find peaks and their indices

    % ----- Use Kernel density estimate to generate distributions ---- %
    modVec = pp.vals(bii,:)+eps; % have to add eps for boundary condition in ksdensity()
    modVec(modVec>=1) = 1-eps; % have to substract eps from values of 1 to stay within boundary conditions
    SWDvec = modVec(SWDlabel);
    baseVec = modVec(~SWDlabel);
    [fi_swd,xi_swd] = ksdensity(SWDvec,kdXP,...
        'Support',[0,1],'Function','cdf');
    [fi_base,xi_base] = ksdensity(baseVec,kdXP,...
        'Support',[0 1],'Function','cdf');

    % ptCut = prctile(pp.vals(bii,~SWDlabel),99); % 99th percentile cut
    ptidx = find(fi_base>=ptThresh,1,'first');
    ptCut = xi_base(ptidx);
    locidx = find(pks1>=ptCut); % find only pks that pass threshold
    LOCS = loc1(locidx); % grab only indices to the peaks that pass threshold
    PKS = pks1(locidx); % grab corresponding peaks
    

    % ---- Probability density functions ------ %
    % nonSWDdist = histcounts(pp.vals(bii,~SWDlabel),dBE, 'Normalization','probability');
    % SWDdist = histcounts(pp.vals(bii,SWDlabel),dBE, 'Normalization','probability');
        [SWDdist,xi_swd] = ksdensity(SWDvec,kdXP,...
        'Support',[0,1],'Function','pdf');
    [nonSWDdist,xi_base] = ksdensity(baseVec,kdXP,...
        'Support',[0 1],'Function','pdf');
    % bhat_coeff = sqrt(SWDdist.*nonSWDdist)
    bhat_coeff = trapz(xi_base, sqrt(SWDdist .* nonSWDdist));
    % bhat_dist = -log(bhat_coeff);

    % --- Make cumulative distribution functions --- %
    nonSWDcdf = histcounts(pp.vals(bii,~SWDlabel),dBE, 'Normalization','cdf');
    SWDcdf = histcounts(pp.vals(bii,SWDlabel),dBE, 'Normalization','cdf');

    % --------------------------- Plotting --------------------------- %
    % ---- Plot cumulative distributions functions --- %
    figure;
    % plot(BC,nonSWDcdf,'k');
    plot(xi_base,fi_base,'k')
    hold on
    plot(xi_swd,fi_swd,'r');
    xline(ptCut);
    % plot(BC,SWDcdf,'r');
    text(.75,.25,sprintf('BC: %.3f',bhat_coeff));
    hold off
    xlim([0 1]);
    ylim([0 1]);

    % ---- Plot proportion population vectors --- %
    figure; plot(pp.time,pp.vals(bii,:),'k');
    hold on; plot(pp.time(SWDlabel),pp.vals(bii,SWDlabel),'r');
    scatter(pp.time(LOCS),PKS,'bo');
    yline(ptCut,'g--');
    % ---------------------------------------------------------------- %

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
    % fprintf('%.3f HSEs per second during non-ictal times\n',HSEni_rate);
    % fprintf('%.3f HSEs per second during ictal times\n',HSEi_rate);
    fprintf('HSE difference: %.3f\n', HSEi_rate-HSEni_rate);
    fprintf('--------------------\n');
    HSE(bii).name = pp.sn{bii};
    HSE(bii).ni = HSEni_rate;
    HSE(bii).ic = HSEi_rate;
    HSE(bii).nn = pp.nn(bii);
    HSE(bii).diff = HSEi_rate-HSEni_rate;
    HSE(bii).bhat_coeff = bhat_coeff;
        % HSE(bii).bhat_dist = bhat_dist;

end
