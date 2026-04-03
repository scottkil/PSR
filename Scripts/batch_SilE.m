%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

twin = 0.025;  % window for HSEs (seconds)
dt = 0.005;    % time step for moving sum (seconds)
bigSilE = [];  % Initialize bigHSE if not already done
RN = []; % initialize recording number vector to store recording number ID
for rii = 1:size(recfin,1)
    loopClock = tic;
    recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %.1f ======= %%\n',...
        recNum);
    topdir = recfin.Filepath_SharkShark_{rii};

    pp = psr_propPop(topdir,twin,dt);
    SWDlabel = psr_labelTimeSWD(topdir, pp.time);
    [SilE] = psr_findSilent(pp, SWDlabel);
    rnr = repmat(recNum,numel(pp.sn),1); % recording number repeated as many times as there are structures in each recording
    RN = [RN;rnr]; % recording number
    title(sprintf('Rec# %.1f',recNum));
    close all
    bigSilE = [bigSilE,SilE];
end

%% Add Recording # to the bigHSE structure %%
for rii = 1:numel(bigSilE)
    bigSilE(rii).recnum = RN(rii);
end

%% Turn it into a data
SilEtable = struct2table(bigSilE);
% writetable(HSEtable, '/home/scott/Documents/PSR/Data/HSEtable_NoDistributions.csv');