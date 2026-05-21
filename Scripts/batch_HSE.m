%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data

% twin = 0.025;  % window for HSEs (seconds)
dt = 0.005;    % time step for moving sum (seconds)
bList = 0.025; %[0.01:0.02:0.21];
minN = 5; % minimum number of neurons to include recording/structure
kList = [1;4;7;10;13];
strList = {'Caudoputamen',...
    'Frontal',...
    'Hipp',...
    'Somatosensory',...
    'Visual'};
HSEvals = {};
for bzii = 1:numel(bList)
    bigHSE = [];  % Initialize bigHSE if not already done
    twin = bList(bzii); % set the time bin size for this iteration
    loopClock = tic;

    for rii = 1:size(recfin,1)
        recNumStr = sprintf('%d.%d',recfin.Subject_(rii),recfin.Recording_(rii));
        recNum = str2num(recNumStr);
        fprintf('%% ======= RECORDING %.1f ======= %%\n',...
            recNum);
        topdir = recfin.Filepath_SharkShark_{rii};

        pp = psr_propPop(topdir,twin,dt);
        SWDlabel = psr_labelTimeSWD(topdir, pp.time);
        [HSE, hf] = psr_findHSE(pp, SWDlabel);
        stcell = {'Baseline';'SWD'}; % for naming figure file below
        for bii = 1:size(hf,1)
            brn = pp.sn{bii}; % brain region name
            for fii = 1:size(hf,2)
                stname = stcell{fii}; % state (baseline or SWD)
                ffName = sprintf('PP_Dist_Estimate_%s_%s.fig',brn,stname); % figure file name
                ffName = fullfile(topdir,ffName);
                saveas(figure(hf(bii,fii)),ffName);
            end
        end
        % --- Add recording number to HSE table --- %
        for nrii = 1:numel(HSE)
            HSE(nrii).recnum = recNum;
        end
        title(sprintf('Rec# %.1f',recNum));
        close all
        bigHSE = [bigHSE,HSE];
        tmpCell = [{HSE.name}',{HSE.vals_SWD}'];
        HSEvals = [HSEvals;tmpCell]; % big cell to store HSE value vectors
    end
    HSEvals(:,3) = {bigHSE.nn};
    HSEvals(:,4) = num2cell(cellfun(@mean, HSEvals(:,2)));
    aaa = cell2table(HSEvals);
    %% Turn it into a data
    HSEtable = struct2table(bigHSE);
    % writetable(HSEtable, '/home/scott/Documents/PSR/Data/HSEtable_NoDistributions.csv');

    for pii = 1:numel(strList)
        k = kList(pii);
        pLog = strcmp(HSEtable.name,strList{pii}) & HSEtable.nn>minN;
        cData = HSEtable.diff(pLog); % iteration-relevant data
        cMat(1,k) =  mean(cData); % mean effect size
        cMat(1,k+1) = std(cData); % standard deviation
        cMat(1,k+2) = sum(pLog); % # of observations
    end
    anvMat(bzii,:) = cMat; %  ANOVA matrix for implementation in Prism
    fprintf('Iteration %d complete! Took %.2f minutes\n',...
        bzii,toc(loopClock)/60);
end % bin duration FOR loop end