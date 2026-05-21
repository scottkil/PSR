function fh = psr_plotEEG_SWDs_Rasters(topdir)
%% psr_plotEEG_SWDs_Rasters Plots the unit rasters, EEG data and 'good' seizures in seizures_EEG.mat
%
% INPUTS:
%   topdir - top-level directory containing EEG data and `seizures_EEG.mat`
%
% OUTPUTS:
%   fh - figure handle to plotted data
%
% Written by Scott Kilianski
% Updated on 2026-04-20
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
KSdir = fullfile(topdir,'kilosort4/');
spikeArray = psr_makeSpikeArray(KSdir);

% --- Load in relevant info --- %
load('UCLA_256F.mat','ycoords');
load('brorder.mat','brorder');
ctFile = sprintf('%sCellInfo.csv',topdir);
CI = readtable(ctFile,...
    'Delimiter',',');       % read in recording info data
CL = CI.CorticalLayer;
[~, nIDX] = ismember(CI.SimpleName,brorder);
chan1ind = CI.ProbeChannel_+1;
chDepth = ycoords(chan1ind); % +1 because probe channels are 0-indexed
inhLog = CI.Inhibitory; % inhibitory neuron log

% --- remove neurons from 'excluded' brain regions --- %
rmLog = strcmp(CI.SimpleName,'Excluded');
CL(rmLog) = [];
chDepth(rmLog) = [];
nIDX(rmLog) = [];
spikeArray(rmLog) = [];
inhLog(rmLog) = [];

% --- Determine order (structure > layer > channel depth) and apply it --- %
[~, finIDX] = sortrows([nIDX,CL,chDepth], [1 2 3], {'ascend' 'ascend','descend'});
CLorder = CL(finIDX);
newOrder = nIDX(finIDX);
SA = spikeArray(finIDX);
inhLog = inhLog(finIDX);

% --- Plot it --- %
fh = figure;
sax(1) = subplot(6,1,1);
psr_plotEEGandSWDs(topdir,sax(1));

clr(1,:) = [255, 63, 85]; % inhibitory
clr(2,:) = [106,85,255]; % unclassified
clr = clr./255; % set to 0 to 1
sax(2) = subplot(6,1,2:6);
hold on
for nii = 1:numel(SA)
    if inhLog(nii) == 1
        cc = clr(1,:);
    else
        cc = clr(2,:);
    end
    yv = ones(numel(SA{nii}),1) * nii;
    xv = SA{nii};
    scatter(xv,yv,36,cc,'|','LineWidth',3);
end

linkaxes(sax,'x');
yticks(1:numel(SA));
for nii = 1:numel(SA)
    tSN = brorder{newOrder(nii)};
    ytl{nii} = sprintf('%s-%d',tSN,CLorder(nii));
end
yticklabels(ytl);
set(sax(2),'YDir','reverse');
xlim tight;
drawnow;

end % function end