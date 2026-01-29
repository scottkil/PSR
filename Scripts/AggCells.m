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
    fprintf('Working on PSR_%d...\n',subnum(ii));
    topdir = TDs{ii};
    xdir = sprintf('%s%s%s',topdir,filesep,'kilosort4/');
    [spikeArray, neuronChans] = psr_makeSpikeArray(xdir);
    try
        load(fullfile(topdir,"electrodeLocations_ManuallyAdjusted.mat"),'electrodeLocations'); % electrode location list
        bcind = neuronChans+1; % make it 1-indexed to use with electrodeLocations
        br = electrodeLocations(bcind,2);
        mbr{ii} = unique(br);
    catch
        fprintf('Electrode locations not found\n');
        br = num2cell(nan(numel(neuronChans),1));
        mbr{ii} = [];
    end
    mn(ii) = subnum(ii);
    sn = ones(numel(br),1) * subnum(ii); % subject number
    recn = ones(numel(br),1) * recnum(ii); % recording number

    % --- Add to list --- %
    BR = [BR;br];
    RN = [RN;recn];
    SN = [SN;sn];

end


%%
% BRnew = BR;
% nanCell = cellfun(@isnan,BRnew,'UniformOutput',false);
% nanLog = cellfun(@(X) numel(X)==1 ,nanCell);
% BRnew(nanLog) = [];
%
[uniqueBR, ~, uidx] = unique(BRnew);
counts = histcounts(uidx, 1:max(uidx)+1)';
