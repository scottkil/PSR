%%
clear all; %close all; clc
d = {'/media/scott2X/PSR_Data/PSR_17/PSR_17_Rec2_231012_124907/';
    '/media/scott2X/PSR_Data/PSR_17_Day2/PSR_17_Rec2_231013_180431/';
    '/media/scott2X/PSR_Data/PSR_18/PSR_18_Rec2_231016_190216/';
    '/media/scott2X/PSR_Data/PSR_20/PSR_20_Rec2_231019_152639/';
    '/media/scott2X/PSR_Data/PSR_22_Day1/PSR_22_Rec2_231215_113847/';
    '/media/scott2X/PSR_Data/PSR_27_Day1/PSR_27_Rec2_250115_141347/';
    '/media/scott2X/PSR_Data/PSR_30_Day1/PSR_30_Day1_Rec2_250125_152426/';
    '/media/scott2X/PSR_Data/PSR_31_Day1/PSR_31_Day1_Rec2_250131_124431/';
    '/media/scott2X/PSR_Data/PSR_32_Day1/PSR_32_Day_Rec1_250127_135424/';
    '/media/scott2X/PSR_Data/PSR_34_Day2/PSR_34_Day2_Rec1_250208_135034/';
    '/media/scott2X/PSR_Data/PSR_35_Day1/PSR_35_Day1_Rec1_250208_183557/';
    '/media/scott4X/PSR_Data_Ext/PSR_37_Day2/PSR_37_Day2_Rec2_250211_120424/';
    '/media/scott4X/PSR_Data_Ext/PSR_38_Day1/PSR_38_Day1_Rec2_250211_203755/';
    '/media/scott4X/PSR_Data_Ext/PSR_38_Day2/PSR_38_Day2_Rec1_250212_174519/';
    '/media/scott4X/PSR_Data_Ext/PSR_39_Day1/PSR_39_Day1_Rec2_250213_174522/';
    '/media/scott4X/PSR_Data_Ext/PSR_39_Day2/PSR_39_Day2_Rec1_250214_153804/';
    '/media/scott4X/PSR_Data_Ext/PSR_40_Day1/PSR_40_Day1_Rec2_250214_225128/'};


st = false(size(d));
pixSize = 0.03143; % millimeters per pixel

pupSize = []; % Col1 is nonSWD. Col2 is SWD
pupMov = []; % Col1 is nonSWD. Col2 is SWD
start_diam = [];
end_diam = [];
start_mov = [];
end_mov = [];
zFlag = 0; % 1 for z-scoring, 0 for none

nzSize = [];
nzMov = [];
for ii = 1:numel(d)
    fprintf('%d out of %d...\n',ii,numel(d));
    try
        pSWD = psr_pupilSWD(d{ii},zFlag);

        pupSize = [pupSize;pSWD.nonSWDsiz,pSWD.SWDsize];
        pupMov = [pupMov;pSWD.nonSWDmov,pSWD.SWDmov];
        start_diam = [start_diam; mean(pSWD.start_diam,1)];
        end_diam = [end_diam; mean(pSWD.end_diam,1)];
        start_mov = [start_mov; mean(pSWD.start_mov,1)];
        end_mov = [end_mov; mean(pSWD.end_mov,1)];
        nzSize = [nzSize;pSWD.nz.nonSWDsize,pSWD.nz.SWDsize];
        nzMov = [nzMov; pSWD.nz.nonSWDmov, pSWD.nz.SWDmov];
        st(ii) = true;
    catch
        continue
    end
end

%% === Pupil Diameter === %%
% YL = [-0.9 0.3];
YL = [0 50];
cf = figure;
sax(1) = subplot(121);
psr_plotMeanSTE(sax(1),pSWD.timeAX,start_diam,'std');
hold on
xline(0,'k--','LineWidth',2);
sax(2) = subplot(122);
psr_plotMeanSTE(sax(2),pSWD.timeAX,end_diam,'std');
hold on
xline(0,'k--','LineWidth',2);
linkaxes(sax,'y');
sax(1).YLim = YL;
set(cf().Children,'FontSize',16);
sax(1).XLabel.String = ('Time from SWD Onset (s)');
sax(2).XLabel.String = ('Time from SWD End (s)');
sax(1).YLabel.String = ('Pupil Diameter (s.d.)');
sax(2).YLabel.String = ('Pupil Diameter (s.d.)');
sax(1).YTick = [-.5 -.25 0];
sax(2).YTick = [-.5 -.25 0];

%% === Pupil Movement === %%
% YL = [-0.5 0.4]; % for z-scored values
YL = [0 0.06];
cf = figure;
sax(1) = subplot(121);
psr_plotMeanSTE(sax(1),pSWD.timeAX,start_mov*pixSize,'std');
hold on
xline(0,'k--','LineWidth',2);
sax(2) = subplot(122);
psr_plotMeanSTE(sax(2),pSWD.timeAX,end_mov*pixSize,'std');
hold on
xline(0,'k--','LineWidth',2);
linkaxes(sax,'y');
sax(1).YLim = YL;
set(cf().Children,'FontSize',16);
sax(1).XLabel.String = ('Time from SWD Onset (s)');
sax(2).XLabel.String = ('Time from SWD End (s)');
sax(1).YLabel.String = ('Pupil Speed (mm/s)');
sax(2).YLabel.String = ('Pupil Speed (mm/s)');