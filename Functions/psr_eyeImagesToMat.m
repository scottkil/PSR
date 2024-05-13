function psr_eyeImagesToMat
%% psr_eyeImagesToMat Reads in eye images and saves to 3D Matlab matrix
%
% INPUTS:
%   None - user selects directory containing eye images
%
% OUTPUTS:
%   None, but saves 'eyeIM' Matlab variable to the selected directory
%
% Written by Scott Kilianski
% Updated on 2024-03-12
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
dd = uigetdir;
rmLog = strcmp({dd.name},'.') | strcmp({dd.name},'..');
dd(rmLog) = [];
topDir = dd(1).folder;
sortedFiles = natsortfiles({dd.name})';
eyeIM = uint8(zeros(128,128,numel(sortedFiles))); % initialize eye image 3D matrix (X,Y,# images)

rwClock = tic;
fprintf('Reading %d image files...\n',numel(sortedFiles))
parfor eyei = 1:numel(sortedFiles) 
    eyeIM(:,:,eyei) = imread(fullfile(topDir,sortedFiles{eyei}));
end
fprintf('Saving to .mat file...\n')
save(fullfile(dd,'eyeIM.mat'),'eyeIM','-v7.3');
fprintf('Done!\nReading and writing took %.2f minutes\n', ...
    toc(rwClock)/60);

end %function end