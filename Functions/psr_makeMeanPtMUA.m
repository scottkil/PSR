function [meanPtMUA, xwin] = psr_makeMeanPtMUA(topdir,halfwinsz)
%% psr_makeMeanPtMUA Makes mean peri-trough MUA for each shank
%
% INPUTS:
%   topdir - top-level directory
%   halfwinsz - half window size (in seconds)
%
% OUTPUTS:
%   meanPtMUA - mean MUA matrix centered on trough. Dim3 is shank number
%   xwin - time vector corresponding to Dim2 in meanPtMUA
%
% Written by Scott Kilianski
% Updated on 2026-04-22
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    halfwinsz = 0.1;
end
    load(fullfile(topdir,'MUA.mat'),'MUA');
    tstep = diff(MUA.time(1:2));    % timestep for MUA plots 
    mua1 = cell2mat(MUA.data(:,1)); % MUA on shank 1
    mua2 = cell2mat(MUA.data(:,2)); % MUA on shank2
    hws = halfwinsz/tstep; % half-window size in samples

    seizFile = fullfile(topdir,'seizures_EEG.mat'); % load in seizures for this recording
    [TT, ttID] = psr_getTroughTimes(seizFile);
    muaSH1 = []; muaSH2 = [];
    for ti = 1:numel(TT)
% --- Get the closest MUA time --- %
        [~, closeIDX] = min(abs(MUA.time-TT(ti)));
% --- Get window around it --- %
        gIDX = (closeIDX-hws):(closeIDX+hws);
        muaSH1(:,:,ti) = mua1(:,gIDX);
        muaSH2(:,:,ti) = mua2(:,gIDX);
    end

meanPtMUA(:,:,1) = mean(muaSH1,3);
meanPtMUA(:,:,2) = mean(muaSH2,3);
xwin = (-hws:hws)*tstep;


end % function end