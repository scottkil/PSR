%% === Load in relevant data === %%
% clear all; close all; clc
topDir = '/media/scott4X/PSR_Data_Ext/PSR_39_Day1/PSR_39_Day1_Rec2_250213_174522/';
pupDir = '/home/scott/DLC_Projects/PSR_39_Day1-Scott-2026-02-10/videos/';


ffn = fullfile(topDir,'analogData.bin');
eegd = psr_binLoadData(ffn,1,3000);
convFactor = 0.0003125; % multiply to convert eeg data into millivolts (assumes 1k gain before input into Intan analog input)
pixSize = 0.03143; % pixel size (in mm)
dd = dir(pupDir);
fnames = {dd.name};
mat_file = fullfile(pupDir,dd(contains(fnames,'.mat')).name);
csv_file = fullfile(pupDir,dd(contains(fnames,'.csv')).name);

C = readcell(csv_file,'Delimiter',',');
pupFile = fullfile(topDir,'pupilData.mat');
load(pupFile,'pupil')
speedFile = fullfile(topDir,'speed.mat');
load(speedFile,'spd');


pup(:,:,1) = cell2mat(C(4:end,2:4));
pup(:,:,2) = cell2mat(C(4:end,5:7));
pup(:,:,3) = cell2mat(C(4:end,8:10));
pup(:,:,4) = cell2mat(C(4:end,11:13));
pup(:,:,5) = cell2mat(C(4:end,14:16));
pup(:,:,6) = cell2mat(C(4:end,17:19));
pup(:,:,7) = cell2mat(C(4:end,20:22));
pup(:,:,8) = cell2mat(C(4:end,23:25));
pup(:,:,9) = cell2mat(C(4:end,26:28));
load(mat_file, 'eyeIM');

%% === Initialize figure === %%
% Tlims = [500 542]; % SET TIME LIMITS FOR THE MOVIE
Tlims = [230 260]; % SET TIME LIMITS FOR THE MOVIE
tWin = 5; % time window size (in seconds) 
movFig = figure;

% --- Eye Image Axis Prep --- %
eyeAX = subplot(2,2,[2,4]);
k = 1; % frame number
eIM = imagesc(eyeIM(:,:,k));
eyeAX.CLim = [0 255];
eyeAX.CLimMode = 'manual';
axis off
colormap(gray)
hold on
bfl = plot(0,0,'m', 'LineWidth', 3);
tl = title('','FontSize',24);

% --- EEG Axis Preparation --- %
eegFS = eegd.finalFS;
hwIDX = tWin/2 * eegFS; % half window size (in # of samples)
eegX = (-hwIDX:hwIDX)/eegFS;
eegY = zeros(size(eegX));
EEGax = subplot(2,2,1);
eegLine = plot(eegX,eegY,'k','LineWidth',1.5);
EEGax.YLimMode = 'manual';
EEGax.YLim = [-2.5 1];
EEGax.XLim = [eegX(1), eegX(end)];
xticks([])
hold on
xline(0,'k--');
hold off
ylabel('Voltage (mV)')
EEGax.FontSize = 18;
EEGax.Title.FontSize = 24;

% --- Speed Axis Preparation --- %
spdFS = 1/diff(spd.time(1:2)); % half window for speed
spd_hw = tWin/2 * spdFS;
spdX = (-spd_hw:spd_hw)/spdFS;
spdY = zeros(size(spdX));
spdAX = subplot(2,2,3);
speedLine = plot(spdX, spdY, 'b', 'LineWidth', 1.5);
spdAX.YLimMode = 'manual';
spdAX.YLim = [0 max(spd.smoothed)];
spdAX.XLim = [spdX(1), spdX(end)];
hold on;
xline(0,'k--');
hold off
spdAX.FontSize = 18;
ylabel('Speed (cm/sec)');
xlabel('Time (sec)')
spdAX.Title.FontSize = 24;

% Find the appropriate frames
subIDX = find(pupil.ft >= Tlims(1) & pupil.ft <= Tlims(2));
% subIDX = subIDX(1:10:end); % DOWNSAMPLING IN TIME TO MAKE LARGE VIDEOS SMALLER
fTimes = pupil.ft(subIDX);
vidName = fullfile(topDir,'pupil_FullSpeed_2.avi');
v = VideoWriter(vidName, 'Motion JPEG AVI');
v.FrameRate = 20;        % frame rate of video
open(v);%

% --- Frame by Frame Update and writing to video --- %
%
for k = 1:length(subIDX)
    [~,yi] = min(abs(eegd.time-fTimes(k))); % get index of EEG sample closest to this frame
    yIDX = (yi-hwIDX):(yi+hwIDX);
    yd  = eegd.data(yIDX);
    set(eegLine,...
        'YData',yd * convFactor);
    
    [~,spdi] = min(abs(spd.time-fTimes(k)));
    spdIDX = (spdi-spd_hw):(spdi+spd_hw);
    spd_d  = spd.smoothed(spdIDX);
    set(speedLine,...
        'YData',spd_d);
    
    % --- Calculate pupil best fit and plot it on image --- %
    eIDX = subIDX(k);
    eIM.CData = eyeIM(:,:,eIDX);
    xp = squeeze(pup(eIDX,1,1:end-1));
    yp = squeeze(pup(eIDX,2,1:end-1));
    confP = squeeze(pup(eIDX,3,1:end-1));
    goodLog = confP > 0.1 ; % only keeping high-confidence points
    xp = xp(goodLog);
    yp = yp(goodLog);
    x = xp;
    y = yp;
    A = [2*x 2*y ones(size(x))];
    b = x.^2 + y.^2;
    p = A\b;
    xc = p(1);
    yc = p(2);
    r  = sqrt(p(3) + xc^2 + yc^2);
    theta = linspace(0,2*pi,400);
    set(bfl,'XData',xc + r*cos(theta),...
        'YData',yc + r*sin(theta));
    
    EEGax.Title.String = sprintf('Time:  %.2f',pupil.ft(eIDX));
    spdAX.Title.String = sprintf('%.2f cm/sec',spd.smoothed(spdi));
    tl.String = sprintf('Pupil Diameter:  %.2fmm',r*2*pixSize);

    drawnow;
    frame = getframe(movFig);      % or getframe(gcf)
    writeVideo(v, frame);

end
close(v);