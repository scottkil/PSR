clear all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');

SWDcount = 0;
for rii = 1:size(recfin,1)
    recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %d.%d ======= %%\n',...
        recfin.Subject_(rii),recfin.Recording_(rii));
    topDir = recfin.Filepath_SharkShark_{rii};
    seizFile = fullfile(topDir, 'seizures_EEG.mat');
    load(seizFile,'seizures');
    keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
    seizures(~keepLog) = [];
    swdMat(rii,1) = recNum; % Store recording number
    swdMat(rii, 2) = numel(seizures); % Update the count of seizures
    SWDcount = SWDcount + numel(seizures);
    TSfile = fullfile(topDir,'timestamps.bin');
tfsID = fopen(TSfile);
TS = fread(tfsID,Inf,'int32=>double'); % timestamps
    recDur = double(TS(end))/(30000*60); % recording duration in minutes
fclose(tfsID);
    swdMat(rii,3) = round(swdMat(rii,2)/recDur,2); % SWDs per minute, rounded to 2 decimal places
    swdMat(rii,4) = recDur;
end