%%
% chI = [97;33;98;34;99;35;100;36;101;37;102;38;103;39;
%     104;40;105;41;106;42;107;43;108;44;109;45;110;46;111;
%     47;112;48;49;19;83;22;86;25;89;28;92;31];
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
% chDepths = [25;75;125;175;225;275;325;375;425;475;525;575;
%     625;675;725;775;825;875;925;975;1025;1075;1125;1175;1225;
%     1275;1325;1375;1425;1475;1525;1575;1625;1675;1725;1775;
%     1825;1875;1925;1975;2025;2075];
chDepths = [0
50
100
150
200
250
300
350
400
450
500
550
600
650
700
750
800
850
900
950
1000
1050
1100
1150
1200
1250
1300
1350
1400
1450
1500
1550
1600
1650
1700
1750
1800
1850
1900
1950
2000
2050];

%%
numChans = 256;
fname = 'Y:\robbieX\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\combined.bin';
md = psr_mapBinData(fname,numChans);
FS = 30000; % sampling frequency
numSamps = size(md.Data.ch,2);
% timeVec = (0:size(dsData,2)-1)/FS;
timeVec = (0:numSamps-1)./FS;
winSize = 0.1;               % in seconds
hwins = round(winSize*FS/2); % half window size (in # samples)
TV = (-hwins:hwins) ./ FS;
TVms = TV*1000;

%%
% -- Load in the SWD data -- %
load('Y:\robbieX\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850\analogData_seizures_curated_20231108_16_00_26.mat','seizures');
rmLog = strcmp({seizures.type},'3');
SWD = seizures(~rmLog);

%%
%% Low band 
lfc = 1; % Lower cutoff frequency in Hz
ufc = 50; % Upper cutoff frequency in Hz

% Set filter coefficients for a Butterworth filter
[b, a] = butter(2, [lfc, ufc]/(FS/2), 'bandpass'); %2nd butterworth filter

%% Retrieve the LFPs during seizure
for szi = 20
    [~, startI] = min(abs(timeVec-SWD(szi).time(1)));
    [~, endI] = min(abs(timeVec-SWD(szi).time(end)));
    szTime = timeVec(startI:endI);
    szData = double(md.Data.ch(chI,startI:endI)); % get LFPs during seizure
    szdMed = median(szData,2); % get the median value for each channel
    medMat = repmat(szdMed,1,size(szData,2)); 
    szdNorm = szData-medMat;   % median subtraction
    filtTraces = filtfilt(b,a,szdNorm')';
    CSD = diff(filtTraces,2,1);
    smoov = imgaussfilt(CSD,2);
    % smoov = CSD;
    % -- Transform the traces so the fit on the heatmap -- %
    plotMat = zscore(filtTraces);
    spacingFactor = 1; % spacing between plots
    modMat = repmat((1:length(chI).*spacingFactor)',1,size(filtTraces,2));
    figure; imagesc(szTime,2:numel(szdMed)-1,smoov);
    colormap(jet);
    clim([-100 100]);
    hold on
    plot(szTime,plotMat+modMat,'k');
    hold off
end

%%
spacingFactor = 5000; % spacing between plots
modVec = (0:length(chI)-1).*spacingFactor;
modMat = repmat(modVec',1,size(filtTraces,2));
figure; 
% plot(szTime,modMat-filtTraces,'k');
plot(szTime,modMat-smoothTraces,'k');
set(gca,'YDir','reverse')

%%
% -- Find time in LFP data closest to SW trough time -- %
% figure;
% trTimes = SWD(1).time(SWD(1).trTimeInds);
% 
% for tri = 1:numel(trTimes)
%     [~, minI] = min(abs(timeVec-trTimes(tri)));
%     cWin = [minI-hwins:minI+hwins];
%     winData = double(md.Data.ch(chI,cWin));
%     modMat = repmat((1:length(chI))'*1000,1,length(cWin));
%     subplot(1,numel(trTimes),tri);
%     plot(TVms,winData'+modMat');
% end