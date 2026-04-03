function ac = psr_propPopAutoCcorr(pp,sstend,ctrl_stend)
%% psr_propPopAutoCcorr Computes the autocorrelation of the proportion population vector during control and SWD periods  
%
% INPUTS:
%   pp - population proportion structure output from psr_propPop
%
% OUTPUTS:
%   ac - autocorrelation structure with following fields:
%       swd - Dim1: SWD #
%             Dim2: time (corresponds to ac.lagT)
%             Dim3: brain structure (corresponds to pp.sn)
%       ctrl - same as 'swd' above but for control periods
%       weight_swd - weighting coefficient for each SWD (based on relative durations)
%       weight_ctrl - weighting coefficient for ctrl periods (based on relative durations)
%       lagT - lag times (in seconds)
%
% Written by Scott Kilianski
% Updated on 2026-03-17
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
FS = 30000;
dt = diff(pp.time(1:2));
maxLag = round(1/dt); % 1 second max lag

for szii = 1:size(sstend,1)
    tmpT = pp.time >= sstend(szii,1) & pp.time <= sstend(szii,2); % current seizure time log
    
    for rii = 1:size(pp.vals,1)
        [AC, LAGS] = xcorr(pp.vals(rii,tmpT),maxLag,'normalized');
        ac.swd(szii,:,rii) = AC;  % store in SWD field
    end
end

for cii = 1:size(ctrl_stend,1)
    tmpT = pp.time >= ctrl_stend(cii,1) & pp.time <= ctrl_stend(cii,2); % current control period time log
    for rii = 1:size(pp.vals,1)
                [AC, LAGS] = xcorr(pp.vals(rii,tmpT),maxLag,'normalized');
    ac.ctrl(cii,:,rii) = AC;  % store in ctrl field
    end
end

% Calculate weighting coefficients for SWD and control periods
szDurs = diff(sstend,[],2); % durations
ac.weight_swd = szDurs/sum(szDurs); % normalized durations
ctrlDurs = diff(ctrl_stend,[],2); % durations
ac.weight_ctrl = ctrlDurs/sum(ctrlDurs); % normalized durations
ac.lagT = LAGS*dt;


end % function end