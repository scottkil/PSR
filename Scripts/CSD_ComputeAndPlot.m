clear all; clc
topdir = '/media/scott2X/PSR_Data/PSR_25/PSR_25_Rec2_First35min/';
% --- LATERAL SHANKS BELOW --- %
% --- Lateral Shank (Full set, 50um spacing) --- %
chI = 1+[96;32;97;33;98;34;99;35;100;36;101;37;102;38;103;39;...
    104;40;105;41;106;42;107;43;108;44;109;45;110;46;111;47;...
    48;18;82;21;85;24;88;27;91;30;94]; % depth-ordered channel indices

% --- MEDIAL SHANKS BELOW --- %
% --- Medial Shank (Full set, 50um spacing) --- %
chI = 1+[159;223;158;222;157;221;156;220;155;219;154;218;153;217;152;216;...
    151;215;150;214;149;213;148;212;147;211;146;210;145;209;144;208;207;...
    237;173;234;170;231;167;228;164;225;161];
dz = 50; % microns
chDepths = ((1:numel(chI))-1)*dz; % relative channel depths (microns)

% Load in relevant data
% -- Memory map the PSR data and set some window parameters -- %
numChans = 256;
% fname = '/media/scott2X/PSR_Data/PSR_15/PSR_15_Rec2_231010_171850/combined.bin';
load(fullfile(topdir,"electrodeLocations.mat"))
fname = fullfile(topdir,'combined.bin');
md = psr_mapBinData(fname,numChans);
FS = 30000; % sampling frequency
numSamps = size(md.Data.ch,2);
timeVec = (0:numSamps-1)./FS;
winSize = 0.1;               % in seconds
hwins = round(winSize*FS/2); % half window size (in # samples)
TV = (-hwins:hwins) ./ FS;   % convert the window to time units (
TVms = TV*1000;              % convert that to milliseconds 

% -- Load in the SWD data -- %
% SWDfn = '/media/scott2X/PSR_Data/PSR_15/PSR_15_Rec2_231010_171850/seizures_EEG.mat';
SWDfn = fullfile(topdir,'seizures_EEG.mat');
load(SWDfn,'seizures');
rmLog = strcmp({seizures.type},'3');
SWD = seizures(~rmLog);
load(fullfile(topdir,"electrodeLocations.mat"))
%% Low pass filter the traces
ufc = 100; % Upper cutoff frequency in Hz
lfc = 3; % low cutoff frequency in Hz
dsFactor = 30; % down sampling factor
fs = FS/dsFactor;
[b, a] = butter(4, [lfc,ufc] / (fs / 2), 'bandpass'); % 4th order bandpass Butterworth filter
scaleFactor = 0.195 * 1e-6;   % factor used to convert amplifier_data unit to VOLTS (0.195 from Intan)

% Calculate CSD for each SWD cycle and store in structure 'CSD'
for szi = 1:1%numel(SWD)
    fprintf('Calculating CSD for SWD #%d...\n',szi);
    % -- Find time in LFP data closest to SW trough time -- %
    trTimes = SWD(szi).time(SWD(szi).trTimeInds); % get trough times from current seizure
    tempCSD = []; % intialize CSD matrix
    tempTime = []; % intialize time matrix
    for tri = 1:numel(trTimes)
        [~, minI] = min(abs(timeVec-trTimes(tri)));      % find closest point in recording to current trough
        startI = minI-hwins;                             % PROBABLY NEED EDGE CONDITIONS FOR THIS!!!!
        endI = minI+hwins;                               % end of cycle index
        dsIndex = startI:dsFactor:endI;                  % create downsampled indexing vector
        cycleTime = timeVec(dsIndex);                    % get the time vector from current cycle
        winData = double(md.Data.ch(chI,dsIndex));       % get LFPs during seizure
        winData = winData.*scaleFactor;                  % convert data to VOLTS
        winMed = median(winData,2);                      % get the median value for each channel
        medMat = repmat(winMed,1,size(winData,2));       % make a matrix with medians for each trace
        winNorm = winData-medMat;                        % median subtraction
        filtTraces = filtfilt(b,a,winNorm')';            % filter normalized traces
        smoothTraces  = smoothdata(filtTraces,1, ...
            "movmean",3);                                % smooth traces vertically 
        [CSDmat, zs] = psr_calcCSD(smoothTraces, ...
            chDepths);                                   % calculate CSD
        tempCSD(:,:,tri) = CSDmat;
        tempTime(tri,:) = cycleTime;
    end
    CSD(szi).mat = tempCSD; %
    CSD(szi).time = tempTime; % 

end

% Plotting
szi = 1;
spacingFactor = 5000; % spacing between plots
modVec = (0:length(chI)-1).*spacingFactor;
% modMat = repmat(modVec',1,size(filtTraces,2));
% figure; 
% plot(szTime,modMat-filtTraces,'k-');
% plot(szTime,modMat-smoothTraces,'k');
% set(gca,'YDir','reverse')
[~, startI] = min(abs(timeVec-SWD(szi).time(1)));
[~, endI] = min(abs(timeVec-SWD(szi).time(end)));
dsIndex = startI:dsFactor:endI;
szTime = timeVec(dsIndex);
szData = double(md.Data.ch(chI,dsIndex)); % get LFPs during seizure
szData = szData.*scaleFactor; % convert data to VOLTS
szdMed = median(szData,2); % get the median value for each channel
medMat = repmat(szdMed,1,size(szData,2)); % make a matrix with medians for each trace
szdNorm = szData-medMat;   % median subtraction
filtTraces = filtfilt(b,a,szdNorm')';
[CSDmat, zs] = psr_calcCSD(filtTraces,chDepths);

smoothTraces = smoothdata(filtTraces,1,'movmean',3);
%%
if 0 
% --- Voltage map plotting --- %
% -- Transform the traces so they fit on the heatmap -- %
spacingFactor = 1; % spacing between plots
tsf = 10^3.5; % trace scale factor (how big the LFP traces are)
sds = 1; % spatial down sample
dsIDX = 1:sds:size(smoothTraces,1);
modVec = (0:length(chI)-1).*spacingFactor;
modMat = repmat(modVec',1,size(filtTraces,2));
figure;
voltAX = axes;
% imagesc(szTime,modVec,smoothTraces);
contourf(szTime,modVec,smoothTraces,100,'LineStyle','none');
set(voltAX,'YDir','reverse');
% clim([-5000 5000]);
colormap(redblue);
colorbar
hold on
% plot(szTime,modMat-(filtTraces*2), ...
%     'k-','LineWidth',1.5);
plot(szTime,modMat(dsIDX,:)-(smoothTraces(dsIDX,:)*tsf), ...
    'Color','k','LineWidth',1.5);
hold off
clim([-.0025 .0025]);
% xlim([1788 1789]);
% exportgraphics(gcf, '/media/scottX/Figures/PSR_Figures/PSR_35_Day1_VoltageMap_zoom.svg')
% xlim([2564 2565])
% exportgraphics(gcf, '/media/scottX/Figures/PSR_Figures/PSR_40_Day1_VoltageMap.svg')
% xlim([2564.2 2564.3])
% exportgraphics(gcf, '/media/scottX/Figures/PSR_Figures/PSR_40_Day1_VoltageMap_zoom.svg')
yd = 1:numel(chI);
yticks(yd)
yticklabels(electrodeLocations(chI,2));
% xlim([217.35 217.53])
end % voltage map plotting
%%
% --- Spatial smoothing across channels with 3-point Hanning window --- %
% hanWin = [0.25; 0.5; 0.25];
% smWin = [1; 4; 6; 4; 1] / 16;
% smTraces = conv2(filtTraces, smWin, 'valid');
% 
% % --- Compute second spatial derivative of the smoothed LFP --- %
% d2V = (smTraces(1:end-2,:) ...
%      - 2*smTraces(2:end-1,:) ...
%      + smTraces(3:end,:)) / dz^2;
% 
% % --- Convert to relative CSD --- %
% CSD = -d2V;
% 
% % --- Depths corresponding to final CSD rows --- %
% csdDepths = chDepths(4:end-3);
% 
% % -- Simple CSD --- %
% chI_mod = chI((3:(end-2))); % indices to channels actually used in CSD generation
% yd = 1:numel(chI_mod);
% % CSDnew = -d2V;
% % figure; imagesc(szTime,yd,CSD);
% figure;imagesc(CSD);
% yticks(yd)
% yticklabels(electrodeLocations(chI_mod,2));


%%
smWin = 5;   % number of channels in Gaussian smoothing window

smTraces = smoothdata(filtTraces, 1, 'gaussian', smWin);

% -- s-golay CSD estimate --- %
sgo = 2;              % quadratic local polynomial
sgolayFrame = 9;      % 7 channels, spanning 300 µm at 50 µm spacing
dz = 50;

[~, g] = sgolay(sgo, sgolayFrame);

d2V = conv2(smTraces, g(:,3), 'valid') * factorial(2) / dz^2;
CSDnew = -d2V;

halfWin = (sgolayFrame - 1) / 2;
chI_mod = chI((1+halfWin):(end-halfWin));

yd = 1:numel(chI_mod);

figure;
imagesc(szTime, yd, CSDnew);
yticks(yd)
yticklabels(electrodeLocations(chI_mod,2));
colormap(jet)
%%
% t = 2156; % pick a time point of interest
% 
% figure;
% 
% subplot(1,2,1)
% plot(filtTraces(:,t), chDepths, '-o')
% set(gca, 'YDir', 'reverse')
% xlabel('LFP')
% ylabel('Depth (\mum)')
% title('LFP across depth')
% 
% subplot(1,2,2)
% plot(CSDnew(:,t), chDepths(3:end-2), '-o')
% set(gca, 'YDir', 'reverse')
% xlabel('CSD')
% ylabel('Depth (\mum)')
% title('SG-estimated CSD across depth')