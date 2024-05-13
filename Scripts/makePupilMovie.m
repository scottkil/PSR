%% Set user-controlled variables
dataDir = 'X:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805';
vfn = 'C:\Users\Scott\Desktop\newvid.avi';  % output video file name goes here
winSizeSec = 10; % time window to display (in seconds)
ecogFS = 30000; % sampling frequency of  ECOG data (30kHz for Intan data)
dseFS = 100; % desired sampling frequency of ECOG data (for purpose of downsampling)
pupilSmoothWin = 20; % in samples

%% --- Retrieve all relevant data --- %%
fprintf('Loading data...\n');
loadClock = tic;
load(fullfile(dataDir,'ECOG.mat'),'ECOG');
load(fullfile(dataDir,'eyeCamInds.mat'),'eyeCamInds');
load(fullfile(dataDir,'eyeIM.mat'),'eyeIM');
load(fullfile(dataDir,'pupil.mat'),'pupil');
fprintf('Loading data took %.2f seconds\n',...
    toc(loadClock));

%% --- Process data --- %
PD = smoothdata(pupil.diameter,'gaussian',pupilSmoothWin); % pupil diameter
MVD = sum(abs(diff(pupil.cxy,1)),2); % pupil movement
MVD = [0;MVD]; % first frame will have 0 movement
MVD = smoothdata(MVD,'gaussian',pupilSmoothWin);
eyeFS = round(ecogFS/median(diff(eyeCamInds)));
tfWIN = round(eyeFS * winSizeSec);
timeWin = (0:tfWIN-1)./eyeFS;
timeLims = [timeWin(1), timeWin(end)];
dsFactor = round(ecogFS/dseFS); %% IS THIS RIGHT??????
physYLIM = max(abs(ECOG))* 1.05; % set limits of physiology axis
diaYLIM = [min(PD)*.95,max(PD)*1.05];
pmYLIM = [min(MVD)*.95,max(MVD)*1.05];

%% --- Initialize figure --- %%
dFig = figure('units','normalized','outerposition',[0 0 1 1]);
rawAX = subplot(2,3,1);
eyeImage = imagesc(zeros(size(eyeIM(:,:,1))));
regCircles = viscircles(rawAX,[0 0], 0,'Color','g');
colormap(gray);
title('Raw Eye Image');
enAX = subplot(2,3,4);
title('Processed Eye Image');
physAX = subplot(2,3,2:3);
title('ECoG');
ecogLine = plot(physAX,0,'k',"LineWidth",1.5);
pupildAX = subplot(2,3,5:6);
diamLine = plot(pupildAX,0,'k',"LineWidth",1.5);
hold on
yyaxis right
moveLine = plot(pupildAX,0,'r',"LineWidth",1.5);
hold off
pupildAX.YAxis(2).Color = 'r';
set(pupildAX.Title,'String','Pupil Diameter and Movement')
set(pupildAX.YAxis(1).Label,'String','Diameter');
set(pupildAX.YAxis(2).Label,'String','Movement');
set(gcf().Children,'FontSize',24);

% !!! IMPLEMENT AUTOMATIC METHOD FOR FINDING LIMITS!!! %
% set(pupildAX.YAxis(1),'LimitsMode','Manual','Limits',diaYLIM);
% set(pupildAX.YAxis(2),'LimitsMode','Manual','Limits',pmYLIM);
set(pupildAX.YAxis(1),'LimitsMode','Manual','Limits',[20 40]);
set(pupildAX.YAxis(2),'LimitsMode','Manual','Limits',[0 4]);
set(pupildAX,'XLimMode','Manual','XLim',timeLims);

set(physAX,'YLimMode','Manual','YLim',[-physYLIM physYLIM]);
set(physAX,'XLimMode','Manual','XLim',timeLims);

%% --- Routine to update plots and save to video --- %% 
vidFS = eyeFS;  % video sampling frequency
writerObj  = VideoWriter(vfn);
writerObj.FrameRate = vidFS;    %
open(writerObj);

% --- Update figure and add frame to video object --- %%
SF = 15400; % start frame
EF = 15900; % end frame

fprintf('Writing to video...\n')
for eyei = SF:EF
    delete(regCircles);
    frameWin = eyei:(eyei+tfWIN)-1;
    ecRange = eyeCamInds(eyei):dsFactor:eyeCamInds(frameWin(end));
    set(ecogLine,'XData',(0:numel(ecRange)-1)/dseFS, ...
        'YData',ECOG(ecRange));
    set(eyeImage,'CData',eyeIM(:,:,eyei));
    set(diamLine,'XData',timeWin, ...
        'YData',PD(frameWin));
    set(moveLine,'XData',timeWin, ...
        'YData',MVD(frameWin));
    regCircles = viscircles(rawAX,pupil.cxy(eyei,:), ...
        pupil.diameter(eyei)/2,'Color','g');
    drawnow;

    F = getframe(dFig);
    writeVideo(writerObj, F);
    pause(0.01);
end
close(writerObj);
fprintf('Done writing video!\n')

%%