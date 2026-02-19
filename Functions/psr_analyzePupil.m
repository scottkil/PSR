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
% Updated on 2026-02-02
% ------------------------------------------------------------ %

%% ---- Function Body Below ---- %%%
if nargin < 2
    plotFlag = 0;
end
% --- Loading data and setting up analysis parameters --- %
fprintf('Loading eyeIM\n')
load(pathToFile, 'eyeIM');
eyeFS = 25; % 25 Hz
mThresh = 12;            % levels to quantize image into
TL = 12;          % quantile to use for threshold (should be <= mThresh)
blinkWin = 25;
bhwin = floor(blinkWin/2); %blink half window
se = strel('disk', 5);  % for image manipulation. Size 10 works well for my pupil imaging

% --- Initialize output variables --- %
pupil_cxy = NaN(size(eyeIM,3),2);    % intialize circle centers matrix (# images, XY positions)
pupil_diameter = NaN(size(eyeIM,3),1);  % initialize circle radii vector (# images)

%% --- Get user input for eye area mask --- %%
eyeFig1 = figure;                   % initialize figure
imshow(min(eyeIM,[],3)); % plot the image
title('Outline the entire eye area. Hit enter to proceed.');
uEye = drawfreehand('Color','r');
% --- Wait for user to draw pupil --- %
while ~strcmp('return',eyeFig1.CurrentKey)
    imMask = uint8(createMask(uEye));
    waitforbuttonpress
end
close(eyeFig1);

% --- Apply eye area mask --- %
emMat = repmat(imMask,1,1,size(eyeIM,3)); % 3D eye mask matrix
sumEyePix = squeeze(sum(eyeIM.*emMat,[1 2])); % sum of pixels in eye area over frames

%% --- Find blinks --- %
fc = .01 ; % high-frequency cutoff (Hz)
[b,a] = butter(4, fc/(eyeFS/2), 'high');
% --- Apply high-pass filter to the summed eye pixels --- %
filteredEyePix = filtfilt(b, a, sumEyePix);
blinkThresh = 99; % threshold percentile to detect blinks
xvv = prctile(filteredEyePix,blinkThresh);
minBlinkDistance = ceil(eyeFS/2); % in samples/frames
[~,blinkIDX] = findpeaks(filteredEyePix,'MinPeakHeight',xvv,'MinPeakDistance',minBlinkDistance);
blinkLog = false(size(sumEyePix));
for bii = 1:length(blinkIDX)
    cidx = (blinkIDX(bii)-bhwin):(blinkIDX(bii)+bhwin);
    if cidx(end) > length(blinkLog) % if blink is too close to end of recording, just go to last frame
        blinkLog(cidx(1):end) = true;
    elseif cidx(1) <= 0 % if blink is too close to start of recording, just go to first frame
        blinkLog(1:cidx(end)) = true;
    else
        blinkLog(cidx) = true;
    end
end

%% --- Get user input to create pupil mask --- %%
eyeFig = figure;                    % Initialize figure
MIPimage = imshow(min(eyeIM,[],3)); % plot the image
title('Draw circle over pupil here. Hit ENTER to proceed.')
% uCircle = drawellipse;               % Get user input
uCircle = drawfreehand('Color','r');

% --- Wait for user to draw pupil --- %
while ~strcmp('return',eyeFig.CurrentKey)
    % pupCen = uCircle.Center;
    % pupRad = uCircle.Radius;
    imMask = uint8(createMask(uCircle));
    waitforbuttonpress
end
close(eyeFig);

eyeFig = figure;
eyeAX = subplot(131);
rawIM = imagesc(eyeAX,zeros(size(eyeIM,1:2)));
colormap(gray);
regCircles = viscircles([0, 0],0);
filtCircles = viscircles([0, 0],0);
enCircles = viscircles([0, 0],0);
filtAX = subplot(132);           % initialize filtered pupil image
filtIM = imagesc(filtAX,zeros(size(eyeIM,1:2)));
enAX = subplot(133); % enhanced image
enIMG = imagesc(enAX,zeros(size(eyeIM,1:2)));

%% --- Main processing loop --- %%
funClock = tic;
fprintf('Starting main processing loop...\n');
for eyei = 1:size(eyeIM,3)
    delete(regCircles);
    delete(filtCircles);
    delete(enCircles);

    eyeFrame = eyeIM(:,:,eyei);
    [BWen,enIM] = processEyeImage(eyeFrame,se,imMask,mThresh,TL);

    % --- Find circles with regionprops --- %
    stats = regionprops("table",BWen,"Centroid", ...
        "MajorAxisLength","MinorAxisLength","Area");
    [~, maxBlobInd] = max(stats.Area);
    stats = table2array(stats);

    if ~isempty(stats)
        pupil_cxy(eyei,:) = stats(maxBlobInd,2:3);
        pupil_diameter(eyei,1) = mean([stats(maxBlobInd,4) stats(maxBlobInd,5)]);
    end

    if ~mod(eyei,100) % every 1000th frame, update
        fprintf('Image # %d\n',eyei);
        set(rawIM,'CData',eyeIM(:,:,eyei));
        regCircles = viscircles(eyeAX,pupil_cxy(eyei,:), ...
            pupil_diameter(eyei)/2,'Color','g');

        set(filtIM,'CData',BWen);
        filtCircles = viscircles(filtAX,pupil_cxy(eyei,:), ...
            pupil_diameter(eyei)/2,'Color','g');

        set(enIMG,'CData',enIM);
        enCircles = viscircles(enAX,pupil_cxy(eyei,:), ...
            pupil_diameter(eyei)/2,'Color','g');
        drawnow;
    end
end

% --- Use detected blinks to blank out these frames --- %
pupil_cxy(blinkLog,1) = NaN;
pupil_cxy(blinkLog,2) = NaN;
pupil_diameter(blinkLog) = NaN;

% --- Store data in the output structure 'pupil' --- %
pupil.cxy = pupil_cxy;
pupil.diameter = pupil_diameter;
pupil.blinkIDX = blinkIDX;

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

function [BWen,enIm] = processEyeImage(eyeFrame,se,imMask,mThresh,TL)
% processes the eye image to produce an enhanced black and white image of
% ideally just the pupil
enIm = imerode(eyeFrame, se);               % erode image to remove fine lines (whiskers + glare lines)
enIm = imdilate(enIm, se);                  % dilate image (to restore edge constrast)
enIm = uint8(255)-enIm;                     % convert to uint8 and invert so pupil is white
enIm = enIm .*imMask;                       % apply user-defined mask
% % imVals = double(enIm(logical(imMask)));
% % imVals = eyeFrame(logical(imMask));
% % [femp, xemp,bw] = ksdensity(double(imVals),0:255,'bandwidth',5);  % 

thresh = multithresh(enIm,mThresh);         % find threshold levels
try 
    labels = imquantize(enIm,thresh);           % quantized based on threshold
catch  % if unable to quantize image, just make it uniform
    labels = ones(size(enIm));
end
BWen = imbinarize(labels,TL);        % binarize for circle-finding later

end