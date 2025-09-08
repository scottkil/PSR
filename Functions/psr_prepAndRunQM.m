function psr_prepAndRunQM(ksdir)
%% psr_prepAndRunQM Prepares recording directory for quality metric functions and then runs them
%
% INPUTS:
%   ksdir - kilosort output directory
%
% OUTPUTS:
%   None
%
% Written by Scott Kilianski
% Updated on 2025-09-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
psr_calcRMS(fullfile(ksdir,'combined.bin'),256);
psr_getSpikeAmps(ksdir);
psr_checkClusters(ksdir);
psr_applyQM(ksdir);
end % function end