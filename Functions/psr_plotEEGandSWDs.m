function fh = psr_plotEEGandSWDs(topdir,ax)
%% psr_plotEEGandSWDs Plots the EEG data and 'good' seizures in seizures_EEG.mat
%
% INPUTS:
%   topdir - top-level directory containing EEG data and `seizures_EEG.mat`
%   ax - axes handle. If it's empty, this will be plotted in a new figure
%
% OUTPUTS:
%   fh - figure handle to plotted data
%
% Written by Scott Kilianski
% Updated on 2026-04-02
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 1
    topdir = uigetdir;
    ax = [];
elseif nargin < 2
    ax = [];
end

% --- Load relevant data --- %
load(fullfile(topdir,'seizures_EEG.mat'),'seizures');
ad = psr_binLoadData(fullfile(topdir,"analogData.bin"),1,1000);

% --- Keep 'good' seizures --- %
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % keep the good seizures
sz = seizures(keepLog); % remove the bad seizures

% --- Plotting --- %
if isempty(ax)
    fh = figure;
else 
    fh = ax.Parent;
end
plot(ad.time, ad.data,'k','LineWidth',1.5); title('EEG');
hold on
yl = get(gca,'YLim');
xlim([ad.time(1) ad.time(end)]);
drawnow;
TT = []; % trough times
TV = []; % trough values 
for ii = 1:numel(sz)
    patch([sz(ii).time(1),sz(ii).time(end),sz(ii).time(end),sz(ii).time(1)],...
        [yl(1),yl(1),yl(2),yl(2)],'g',...
        'EdgeColor','none','FaceAlpha',0.25);
    tt = sz(ii).time(sz(ii).trTimeInds);
    TT = [TT;tt];
    tv = sz(ii).EEG(sz(ii).trTimeInds);
    TV = [TV;tv];
end
scatter(TT,TV,'bo');

end % function end
