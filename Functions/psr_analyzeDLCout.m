function pupil = psr_analyzeDLCout(pathToDLCout)
%% psr_analyzeDLCout Analyzes pupil diameter and movement from DeepLabCut .csv output files
%
% INPUTS:
%   pathToDLCout - path to DeepLabCut output .csv file (typically called 'pupilDLC.csv')
%
% OUTPUTS:
%   pupil - structure with the following fields:
%            - cxy: circle (pupil) centers
%            - rad: radius (in number of pixels)
%            - mL:  mean likelihood (gives estimate of confidence in marker positions, from DLC)
%
% Written by Scott Kilianski
% Updated on 2026-02-09
% ------------------------------------------------------------ %

%% ---- Function Body Below ---- %%%
C = readcell(pathToDLCout,'Delimiter',',');         % read .csv output from DeepLabCut

% --- Reading in the marker positions from DLC output .csv file --- %
pup(:,:,1) = cell2mat(C(4:end,2:4));
pup(:,:,2) = cell2mat(C(4:end,5:7));
pup(:,:,3) = cell2mat(C(4:end,8:10));
pup(:,:,4) = cell2mat(C(4:end,11:13));
pup(:,:,5) = cell2mat(C(4:end,14:16));
pup(:,:,6) = cell2mat(C(4:end,17:19));
pup(:,:,7) = cell2mat(C(4:end,20:22));
pup(:,:,8) = cell2mat(C(4:end,23:25));
% pup(:,:,9) = cell2mat(C(4:end,26:28)); % 9th point is the estimated circle center from DLC (not very accurate)

numIT = size(pup,1);
% --- Initialize variables to store relevant outputs --- %
xc = nan(numIT,1);
yc = nan(numIT,1);
r = nan(numIT,1);
% mL = nan(numIT,1);
% ------------------------------------------------------ %

%%
% --- Calculate the circle centers and radii --- %
parfor k = 1:numIT

    xp = squeeze(pup(k,1,:));
    yp = squeeze(pup(k,2,:));
    sml = squeeze(pup(k,3,:)); % likelihood values

    % --- only use points with likelihood > 0.1 for circle estimation --- %
    goodLog = sml > 0.1 ; % only keeping high-confidence points
    if isempty(goodLog)
        continue % if there are no high likelihood estimates, skip this frame
    end
    x = xp(goodLog);
    y = yp(goodLog);

    A = [2*x 2*y ones(size(x))];
    b = x.^2 + y.^2;

    p = A\b;    % best-fit circle parameters
    xc(k) = p(1);  % x coordinate of circle center
    yc(k) = p(2);  % y coordinate of circle center
    r(k)  = sqrt(p(3) + p(1)^2 + p(2)^2); % radius (in pixels)
    mL(k) = mean(sml);
end
%%

% theta = linspace(0,2*pi,400); % evaluated circle points

% --- Store output variables --- %
pupil.cxy = [xc,yc];    % circle centers matrix (# images x XY positions)
pupil.rad = r;          % circle radii (# images, measured in number of pixels)
pupil.mL = mL;         % mean likelihood


end % function end