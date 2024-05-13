function psr_plotEEGandRasters(EEG,spikeScatter,timeLims)
%% psr_plotEEGandRasters Plots EEG and Rasters within time limits
%
% INPUTS:
%   EEG - structure containing EEG info and data
%   spikeScatter - cell array. Each cell has spike times (col1) and spike
%                  unit IDs (col2)
%   timeLims - 2-element vector. Start and end times to be plotted
%
% OUTPUTS:
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
for szi = 1:numel(spikeScatter)
    X = spikeScatter{szi}(:,1);     % spike times
    Y = spikeScatter{szi}(:,2);     % unit numbers
    keepLog = EEG.time>timeLims(szi,1) & EEG.time<timeLims(szi,2); % get spikes w/in time limits
    EEGdata = EEG.data(keepLog);    % keep EEG data in limits
    EEGtime = EEG.time(keepLog);    % corresponding times
    figure;
    ax(1) = subplot(211);
    plot(EEGtime,EEGdata,'k');
    ax(2) = subplot(212);
    scatter(X,Y,72,'|');
    linkaxes(ax,'x');
    xlim(timeLims(szi,:));
end
end % function end