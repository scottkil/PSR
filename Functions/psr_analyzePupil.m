function pupil = psr_analyzePupil(pathToFile,plotFlag)
%% psr_analyzePupil Analyzes pupil diameter and movement
%
% INPUTS:
%   pathToFile - path to eyeIM.mat file (output of psr_eyeImagesToMat)
%   plotFlag - plotting flag. Plot shows estimated pupil position and diameter over time
%
% OUTPUTS:
%   pupil - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2024-03-18
% ------------------------------------------------------------ %

%% ---- Function Body Below ---- %%%
if nargin < 2
    plotFlag = 0;
end
% --- Loading data and setting up analysis parameters --- %
% pathToFile = 'X:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805\eyeIM.mat';
load(pathToFile, 'eyeIM');
mThresh = 8;            % image level threshold
sigma = 0.25;           % for guassian image filtering
se = strel('disk', 2);  % for image manipulation
% rMin = 8;
% rMax = 25;
% circSensitivity = .85;

% --- Initialize output variables --- %
pupil_cxy = NaN(size(eyeIM,3),2);    % intialize circle centers matrix (# images, XY positions)
pupil_diameter = NaN(size(eyeIM,3),1);  % initialize circle radii vector (# images)

%% --- Get user input for to create image mask --- %%
eyeFig = figure;                    % Initialize figure
MIPimage = imshow(min(eyeIM,[],3)); % plot the image
title('Draw circle over pupil here. Hit ENTER to proceed.')
uCircle = drawcircle;               % Get user input

% --- Wait for user to draw pupil --- %
while ~strcmp('return',eyeFig.CurrentKey)
    % pupCen = uCircle.Center;
    % pupRad = uCircle.Radius;
    imMask = uint8(createMask(uCircle));
    waitforbuttonpress
end
close(eyeFig);

eyeFig = figure;
eyeAX = axes;
rawIM = imagesc(zeros(size(eyeIM,1:2)));
colormap(gray);
regCircles = viscircles([0, 0],0);

%% --- Main processing loop --- %%
funClock = tic;
fprintf('Starting main processing loop...\n');
for eyei = 1:size(eyeIM,3)
    delete(regCircles);
    if ~mod(eyei,2000)
        fprintf('Image # %d\n',eyei);
    end
    eyeFrame = eyeIM(:,:,eyei);
    BWen = processEyeImage(eyeFrame,sigma,se,imMask,mThresh);

    % --- Find circles with regionprops --- %
    stats = regionprops("table",BWen,"Centroid", ...
        "MajorAxisLength","MinorAxisLength","Area");
    [~, maxBlobInd] = max(stats.Area);
    stats = table2array(stats);
    
    % [circcen, radi] = imfindcircles(BWen,[rMin rMax], ...
    %     'ObjectPolarity','bright', ...
    %     'Sensitivity', circSensitivity);
    % [radi, Sind] = sort(radi,'descend');
    % circcen = circcen(Sind,:);

    if ~isempty(stats)
        pupil_cxy(eyei,:) = stats(maxBlobInd,2:3);
        pupil_diameter(eyei,1) = mean([stats(maxBlobInd,4) stats(maxBlobInd,5)]);
    end
    set(rawIM,'CData',eyeIM(:,:,eyei));
    regCircles = viscircles(eyeAX,pupil_cxy(eyei,:), ...
        pupil_diameter(eyei)/2,'Color','g');
    drawnow;

end

% --- Store data in the output structure 'pupil' --- %
pupil.cxy = pupil_cxy;
pupil.diameter = pupil_diameter;
% smoothPup = smoothdata(pupil_diameter,"gaussian",20);

fprintf('Getting pupil stats took %.2f minutes\n',toc(funClock)/60);

if plotFlag
    figure;
    sax(1) = subplot(211);
    plot(pupil.diameter);
    ylabel('Diameter');
    xticklabels({});
    sax(2) = subplot(212);
    eyeMovement = sum(abs(diff(pupil_cxy,[],1)),2);
    plot(eyeMovement);
    ylabel('Movement');
    linkaxes(sax,'x');
end

end % function end

function BWen = processEyeImage(eyeFrame,sigma,se,imMask,mThresh)
% processes the eye image to produce an enhanced black and white image of
% ideally just the pupil
    enIm = imgaussfilt(eyeFrame, sigma);        % guassian filter
    enIm = imerode(enIm, se);                   % erode image
    enIm = imdilate(enIm, se);                  % dilate image
    enIm = uint8(255)-enIm;                     % conver to uint8 and invert so pupil is white
    enIm = enIm .*imMask;                       % apply user-defined mask
    thresh = multithresh(enIm,mThresh);         % apply levels threshold
    labels = imquantize(enIm,thresh);           % quantized based on threshold
    BWen = imbinarize(labels,mThresh-1);        % binarize for circle-finding below
end