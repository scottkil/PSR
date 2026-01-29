%% Get locations of cells
clear all; clc
csvin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');
% TDs = csvin.Filepath_SharkShark_; % Extract TDs from the input table
TDs{1} = '/media/scott2X/PSR_Data/PSR_15/PSR_15_Rec2_231010_171850/';
TDs{2} = '/media/scott2X/PSR_Data/PSR_17_Day2/PSR_17_Rec2_231013_180431/';
TDs{3} = '/media/scott2X/PSR_Data/PSR_18/PSR_18_Rec2_231016_190216/';
recnum = [1, 1, 2]; % Extract recording number from the input table
subnum = [15, 17, 18];

%% Loop for each recording
% How do I handle missing histology??? Skip for now I guess %
BR = {}; % Initialize BR cell array to store results
SN = [];
RN = [];

for ii = 1:numel(TDs)
    fprintf('Working on PSR_%d...\n',subnum(ii));
    topdir = TDs{ii};
    xdir = sprintf('%s%s',topdir,'kilosort4/');
    [spikeArray, neuronChans] = psr_makeSpikeArray(xdir);
    try
        load(fullfile(topdir,"electrodeLocations.mat"),'electrodeLocations'); % electrode location list
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
BRnew = BR;
[uniqueBR, ~, uidx] = unique(BRnew);
counts = histcounts(uidx, 1:max(uidx)+1)';
