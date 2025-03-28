function psr_plotEEGandRastersandMUA(EEG,spikeScatter,MUA,timeLims)
%% psr_plotEEGandRastersandMUA Plots EEG and spike rasters and MUA within time limits
%
% INPUTS:
%   EEG - structure containing EEG info and data
%   spikeScatter - cell array. Each cell has spike times (col1) and spike
%                  unit IDs (col2)
%   MUA - cell array wherein numel(MUA) = #SWDs. In each cell, row1 is time vector, row2 is time-binned sum of all spikes
%   timeLims - 2-element vector. Start and end times to be plotted
%
% OUTPUTS:
%   plots
%
% Written by Scott Kilianski
% Updated on 2024-08-13
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
for szi = 1:numel(spikeScatter)
    X = spikeScatter{szi}(:,1);     % spike times
    Y = spikeScatter{szi}(:,2);     % unit numbers
    keepLog = EEG.time>timeLims(szi,1) & EEG.time<timeLims(szi,2); % get spikes w/in time limits
    EEGdata = EEG.data(keepLog);    % keep EEG data in limits
    EEGtime = EEG.time(keepLog);    % corresponding times
    figure;
    ax(1) = subplot(5,1,1:2);
    plot(EEGtime,EEGdata,'k');
    ax(2) = subplot(5,1,3:4);
    scatter(X,Y,72,'|');
    ax(3) = subplot(5,1,5);
    bar(MUA{szi}(1,:),MUA{szi}(2,:),'k');
    linkaxes(ax,'x');
    xlim(timeLims(szi,:));
end
end % function end