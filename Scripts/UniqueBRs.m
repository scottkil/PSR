%% Get locations of cells
clear all; close all; clc
csvin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');
TDs = csvin.Filepath_SharkShark_; % Extract TDs from the input table
recnum = csvin.Recording_; % Extract recording number from the input table
subnum = csvin.Subject_;

%% Loop for each recording
% How do I handle missing histology??? Skip for now I guess %
BR = {}; % Initialize BR cell array to store results
SN = [];
RN = [];

for ii = 1:numel(TDs)
    topdir = TDs{ii};
    load(fullfile(topdir,"ClusterLocations_ManuallyAdjusted.mat"),'br'); % electrode location list
    sn = ones(size(br,1),1) * subnum(ii); % subject number
    recn = ones(size(br,1),1) * recnum(ii); % recording number
    
    % --- Add to list --- %
    BR = [BR;br];
    RN = [RN;recn];
    SN = [SN;sn];

end

%%
uniqueBR = unique(BR(:,1));