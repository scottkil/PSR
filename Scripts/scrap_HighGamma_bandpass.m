%% === Load in top-level data === %%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');
dirList = recfin.Filepath_SharkShark_;
bigR = {};
for rii = 1:size(dirList,1)
    try
        fDir = dirList{rii};

        fprintf('Working on %s...\n',fDir)
      bigR{rii,1} = scrapFun_HGcorr(fDir);
    catch e
        fprintf(1, 'Error Message: %s\n', e.message);
        bigR{rii,1} = NaN;
    end
end

%%
for rii = 1:numel(bigR)
    tmpSTR = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum(rii)= str2num(tmpSTR);
    % figure;
    % histogram(bigR{rii})
end