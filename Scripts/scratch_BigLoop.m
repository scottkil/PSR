%% === Load mean vectors === %%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');

%% === Main Processing Loop Below === %%

% --- Put any intialization steps here --- %
% BigDataMatrix = []; % initialize a storage matrix

for ii = 1:size(recfin,1)
    loopClock = tic;
    tdir = recfin.Filepath_SharkShark_{ii};
    fprintf('Working on %s...\n',tdir);

    % --- Plug in processing code here --- %
    % tempData = processRecording(tdir);         % do the processing
    % BigDataMatrix = [BigDataMatrix; tempData]; % add the output to the storage matrix
    % ------------------------------------ %

    elapsedTime = toc(loopClock);
    fprintf('Completed in %.2f minutes.\n', elapsedTime/60);
end