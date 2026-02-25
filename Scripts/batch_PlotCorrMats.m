%%
clear all; close all; clc
%%
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names
uqrid = unique(dtbl.RecID); % find the

%%
bigArray = {};
for rii = 17%1:size(recfin,1)

    % --- Set up for current iteration --- %
    outCell = {}; % intialize the temporary output cell array
    recID = uqrid(rii);  % get the current iteration recording ID
    fprintf("Working on Rec# %.1f\n",recID);
    cLog = dtbl.RecID == recID; % find all neurons in the current recording
    sn = simpName(cLog);        % get the structure names for these neurons
    tdir = recfin.Filepath_SharkShark_{rii}; % set the top-level directory for this recording

    % --- Compute average pairwise correlations --- %
    Rmean = psr_plotCorrMats(tdir,sn);  % get pairwise correlations
    
    Rmean.swd(isnan(Rmean.swd)) = 0;   % replace NaNs with 0s for plotting
    Rmean.ctrl(isnan(Rmean.ctrl)) = 0; % replace NaNs with 0s for plotting

    cf = figure;
    subplot(121);
    imagesc(Rmean.ctrl);
    clim([-1 1]); colormap(redblue);
    title('Baseline');
    subplot(122);
    imagesc(Rmean.swd);
    clim([-1 1]); colormap(redblue);
    title('SWD');
    set(cf().Children,'FontSize',18)
    % set(cf().Children,'XTicks',[])

end