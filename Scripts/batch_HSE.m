%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

twin = 0.025;  % window for HSEs
dt = 0.005;    % time step for moving sum
bigHSE = [];  % Initialize bigHSE if not already done
for rii = 1:size(recfin,1)
    loopClock = tic;
    recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
    recNum = str2num(recNumStr);
    fprintf('%% ======= RECORDING %.1f ======= %%\n',...
        recNum);
    topdir = recfin.Filepath_SharkShark_{rii};

    pp = psr_propPop(topdir,twin,dt);
    SWDlabel = psr_labelTimeSWD(topdir, pp.time);
    HSE = psr_findHSE(pp, SWDlabel);
    rnr = repmat(recNum,numel(pp.sn),1); % recording number repeated as many times as there are structures in each recording
    RN = [RN;rnr]; % recording number
    close all
    bigHSE = [bigHSE,HSE];
end

%% Add Recording # to the bigHSE structure %%
for rii = 1:numel(bigHSE)
    bigHSE(rii).recnum = RN(rii);
end

HSEtable = struct2table(bigHSE);