%% Set up channel information
chI = [97
33
98
34
99
35
100
36
101
37
102
38
103
39
104
40
105
41
106
42
107
43
108
44
109
45
110
46
111
47
112
48
49
19
83
22
86
25
89
28
92
31];
chDepths = [0:50:2050]';
ch1Depth = 50; % adjustable
chDepths = chDepths+ch1Depth; 

%% Memory map the PSR data and set some window parameters
numChans = 256;
fname = 'Y:\robbieX\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\combined.bin';
md = psr_mapBinData(fname,numChans);
FS = 30000; % sampling frequency
numSamps = size(md.Data.ch,2);
timeVec = (0:numSamps-1)./FS;
winSize = 0.1;               % in seconds
hwins = round(winSize*FS/2); % half window size (in # samples)
TV = (-hwins:hwins) ./ FS;   % convert the window to time units (
TVms = TV*1000;              % convert that to milliseconds 

%% Load in the SWD data 
load('Y:\robbieX\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\analogData_seizures_curated_20231108_16_00_26.mat','seizures');
rmLog = strcmp({seizures.type},'3');
SWD = seizures(~rmLog);

%% Low band 
% lfc = 1; % Lower cutoff frequency in Hz
ufc = 50; % Upper cutoff frequency in Hz
dsFactor = 30; % down sampling factor
fs = FS/dsFactor;
% Set filter coefficients for a Butterworth filter
% [b, a] = butter(2, [lfc, ufc]/(FS/2), 'bandpass'); %2nd butterworth filter
[b, a] = butter(4, ufc / (fs / 2), 'low');
scaleFactor = 0.195 * 1e-6;   % factor used to convert amplifier_data unit to VOLTS (0.195 from Intan)
scaleFactor = 0.195 * 1e-3;   % factor used to convert amplifier_data unit to millivolts (0.195 from Intan)

%% Retrieve the LFPs during seizure
for szi = 20
    % % -- Find time in LFP data closest to SW trough time -- %
% trTimes = SWD(1).time(SWD(1).trTimeInds(1));
% for tri = 1:numel(trTimes)
%     [~, minI] = min(abs(timeVec-trTimes(tri)));
%     cWin = [minI-hwins:minI+hwins];
%     winData = double(md.Data.ch(chI,cWin));
%     modMat = repmat((1:length(chI))'*1000,1,length(cWin));
%     subplot(1,numel(trTimes),tri);
%     plot(TVms,winData'+modMat');
% end
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
    
    % -- Transform the traces so the fit on the heatmap -- %
    spacingFactor = 1; % spacing between plots
    modVec = (0:length(chI)-1).*spacingFactor;
    modMat = repmat(modVec',1,size(filtTraces,2));
    figure; 
    imagesc(szTime,modVec,filtTraces);
    % clim([-5000 5000]);
    colormap(redblue);
    hold on
    % plot(szTime,modMat-(filtTraces*2), ...
    %     'k-','LineWidth',1.5);
    plot(szTime,modMat-(smoothTraces*1), ...
        'k-','LineWidth',1.5);
    hold off
end

%%
spacingFactor = 5000; % spacing between plots
modVec = (0:length(chI)-1).*spacingFactor;
modMat = repmat(modVec',1,size(filtTraces,2));
% figure; 
plot(szTime,modMat-filtTraces,'k-');
% plot(szTime,modMat-smoothTraces,'k');
% set(gca,'YDir','reverse')

