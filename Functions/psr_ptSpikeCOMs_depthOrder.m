function [sh, fullCom, figOut] = psr_ptSpikeCOMs_depthOrder(ptPETH,BC,shLog,smoothwin,plotFlag,depthOrder)
%% psr_ptSpikeCOMs Finds and plots center-of-mass (COM) for peri-trough spiking
%
% INPUTS:
%   ptPETH - peri-trough time histogram for neuron spiking with following dimensions:
%      Dim1 - neurons
%      Dim2 - times (relative to trough) (in seconds). Same length as `BC`
%      Dim3 - troughs. Individual SWD troughs of recording
%   BC - bin centers (in seconds). Same length as Dim2 of `ptPETH`
%   shLog - shank logical vector. shLog(:,1) has TRUEs for neurons on shank 1. shLog(:,2) has TRUEs for neurons on shank 2
%   smoothwin - smoothing window (in samples). Always operates across columns (i.e. Dim2 of ptPETH). Default is 10
%   plotFlag - 1 for plotting. 0 for none. Default is 1
%   depthOrder - information about depth order (sorted depth in col1, order index in col2, rows are shanks 1 and 2)
%
% OUTPUTS:
%   sh - structure with shank-by-shank peri-trough data. Field ".one" and ".two" have the following subfields:
%       com: center of mass times. Col1 is for first half. Col2 is for 2nd half
%       ord: order of the c-o-m times. Col1 is for first half. Col2 is for 2nd
%       mat: peri-trough time histogram matrix with dimensions:
%         Dim1 - neurons
%         Dim2 - time
%         Dim3 - trough halves (1st and 2nd half)
%   fullCom - center-of-mass for all neurons across all troughs (index units - useful for plotting)
%   figOut - handle to output figure. [] if plotFlag is 0.
%
% Written by Scott Kilianski
% Updated on 2026-04-24
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 3
    smoothwin= 10;
    plotFlag = 1;
elseif nargin < 4
    plotFlag = 1;
end

%% === Center-of-mass values across all troughs === %%
meanptp = mean(ptPETH,3,'omitmissing'); % get mean peri-trough histogram across all troughs
normMat = psr_makePlotMatrix(meanptp,smoothwin); % smooth and normalize it

% --- Find center-of-mass indices --- %
idx = 1:size(ptPETH,2);
for ni = 1:size(ptPETH,1)
    fullCom(ni,1) = sum(idx .* normMat(ni,:)) / sum(normMat(ni,:)); % center-of-mass
end


%% === Now separate by 1st and 2nd half of all troughs === %%
% --- Half and half split of trough times --- %
nT = size(ptPETH,3);
ttLog1 = (1:nT) < (nT/2); % logical to first half of all troughs
tstep = diff(BC(1:2)); % time step

% --- Get mean and smoothed matrices across 1st and 2nd halves of troughs --- %
for hii = 1:2
    if hii == 1
        currLog = ttLog1; % first half of troughs
    else
        currLog = ~ttLog1; % second half of troughs
    end

    % --- Average over troughs --- %
    meanptp = mean(ptPETH(:,:,currLog),3,'omitmissing');
    normMat = psr_makePlotMatrix(meanptp,smoothwin);

    % --- Find center-of-mass indices --- %
    idx = 1:size(ptPETH,2);
    for ni = 1:size(ptPETH,1)
        comV(ni,hii) = sum(idx .* normMat(ni,:)) / sum(normMat(ni,:)); % center-of-mass
    end

    % --- Separate units by shank --- %
    sh1Mat(:,:,hii) = normMat(shLog(:,1),:);
    sh2Mat(:,:,hii) = normMat(shLog(:,2),:);
end

% --- converting center-of-mass values to trough-relative times --- %
midIdx = size(sh1Mat,2)/2; % middle index
comT = (comV-midIdx)*tstep;

% --- Sort units by their center-of-mass order --- %
halfLead = 1; % pick which half of trough times to use for plotting (1 or 2)
if halfLead == 1
    halfFollow = 2;
else
    halfFollow = 1;
end
for hii = 1:2
    orig1(:,hii) = comT(shLog(:,1),hii); % original ordered center-of-mass times - shank 1
    orig2(:,hii) = comT(shLog(:,2),hii); % original ordered center-of-mass times - shank 2
    [comv1(:,hii), ord1(:,hii)] = sort(orig1(:,hii),'ascend');
    [comv2(:,hii), ord2(:,hii)] = sort(orig2(:,hii),'ascend');
end

%% === Plotting peri-trough histograms and center-of-mass times for each shank === %%
oSize = 54;
if plotFlag
    figOut = figure;
    subplot(121);
    yd = 1:size(sh1Mat,1);
    % Cord = ord1(:,halfLead);
    Cord = depthOrder{1,2}; % SORTED BY DEPTH
    imagesc(BC,yd,sh1Mat(Cord,:,halfLead));
    hold on
    xlv = orig1(Cord,halfLead); % x-line values
    plot(xlv,yd,'r','LineWidth',2);
    xlv2 = orig1(Cord,halfFollow); % x-scatter values
    scatter(xlv2,yd,oSize,'g','o','LineWidth',2);
        % --- Show y-coordinates --- %
    yticks(1:numel(yd));
    yticklabels(depthOrder{1,1});  % y-coordinates
    ylabel('Depth from surface (microns)');
    % -------------------------- %

    subplot(122);
    yd = 1:size(sh2Mat,1);
    % Cord = ord2(:,halfLead);
    Cord = depthOrder{2,2}; % SORTED BY DEPTH
    plotMat = sh2Mat(Cord,:,halfLead);
    imagesc(BC,yd,plotMat);
    hold on
    xlv = orig2(Cord,halfLead); % x-line values
    plot(xlv,yd,'r','LineWidth',2);
    xlv2 = orig2(Cord,halfFollow); % x-scatter values
    scatter(xlv2,yd,oSize,'g','o','LineWidth',2);
    % --- Show y-coordinates --- %
    yticks(1:numel(yd));
    yticklabels(depthOrder{2,1}); 
    ylabel('Depth from surface (microns)');
    % -------------------------- %
    colormap(flipud(bone));
else
    figOut = [];
end

%% === A little packaging to make the output nice === %%
sh.one.ord = ord1;
sh.one.mat = sh1Mat;
sh.one.com = orig1;
sh.two.ord = ord2;
sh.two.mat = sh2Mat;
sh.two.com = orig2;
end % function end