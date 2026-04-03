function [FRs] = psr_overallFRs(topdir)
%% psr_overallFRs Gets firing rates during SWD, stillness, and motion
%  
% INPUTS:
%   topdir - filepath to top-level directory
%
% OUTPUTS:
%   FRs - firing rates (spikes/sec) over the entire recording
%
% Written by Scott Kilianski
% Updated on 2026-04-03
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
FS = 30000; % original sampling frequency (almost always 30kHz)
TSfile = fullfile(topdir,'timestamps.bin');
tfsID = fopen(TSfile);
TS = fread(tfsID,Inf,'int32=>double'); % timestamps
fclose(tfsID);

%%
[spikeArray] = psr_makeSpikeArray_TS(fullfile(topdir,'/kilosort4/'));
spikeCount = cellfun(@numel,spikeArray);
FRs = spikeCount./(double(TS(end))/FS);
end % function end
