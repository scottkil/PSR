%%
clear all; close all; clc
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

lpCut = 2; % 2 Hz

st = false(size(d));
for ii = 1:numel(d)
    topDir = d{ii};
    fprintf('%s\n',topDir);
    try
        psr_processPupilData(topDir,lpCut);
        st(ii) = true;
    catch
    end
end