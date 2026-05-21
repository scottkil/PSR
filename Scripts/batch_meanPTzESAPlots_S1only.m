%% Loop over all relevant recordings and do
clear all; close all; clc
% --- All S1 recordings --- %
rec{1} = '/media/scott2X/PSR_Data/PSR_07/PSR_07_Rec2_230915_135414/';
rec{2} = '/media/scott2X/PSR_Data/PSR_15/PSR_15_Rec2_231010_171850/';
% rec{3} = '/media/scott2X/PSR_Data/PSR_17/PSR_17_Rec2_231012_124907/'; % no 'electrodeLocations' because no histology
rec{3} = '/media/scott2X/PSR_Data/PSR_17_Day2/PSR_17_Rec2_231013_180431/';
rec{4} = '/media/scott2X/PSR_Data/PSR_25/PSR_25_Rec2_First35min/';
rec{5} = '/media/scott2X/PSR_Data/PSR_30_Day1/PSR_30_Day1_Rec2_250125_152426/';
rec{6} = '/media/scott2X/PSR_Data/PSR_31_Day1/PSR_31_Day1_Rec2_250131_124431/';
rec{7} = '/media/scott2X/PSR_Data/PSR_35_Day1/PSR_35_Day1_Rec1_250208_183557/';
rec{8} = '/media/scott2X/PSR_Data/PSR_35_Day2/PSR_35_Day2_Rec2_250209_094602/';
rec{9} = '/media/scott4X/PSR_Data_Ext/PSR_38_Day1/PSR_38_Day1_Rec2_250211_203755/';
rec{10} = '/media/scott4X/PSR_Data_Ext/PSR_38_Day2/PSR_38_Day2_Rec1_250212_174519/';
rec{11} = '/media/scott4X/PSR_Data_Ext/PSR_40_Day1/PSR_40_Day1_Rec2_250214_225128/';
rec{12} = '/media/scott4X/PSR_Data_Ext/PSR_40_Day2/PSR_40_Day2_Rec1_250215_173210/';
shankNum = 1;
winSize = 0.15;

pfFile = sprintf('/home/scott/Documents/ptzESA_shank%d.pdf',shankNum);

for rii = 1:numel(rec)
    fprintf('%% ======= RECORDING %s ======= %%\n',...
        rec{rii});
    mpt = psr_mean_ptESAbyDepth(rec{rii}, shankNum, winSize);
    ptzESAfig = figure; 
    contourf(mpt.time,1:size(mpt.mat,1),mpt.mat,100,'LineStyle','none');
    imagesc(mpt.time,1:size(mpt.mat,1),mpt.mat);
    set(gca,'YDir','reverse')
    yticks(1:size(mpt.mat,1))
    yticklabels(mpt.br);
    colorbar
    drawnow;        
    exportgraphics(ptzESAfig, pfFile,...
            'Append', true);
    close(ptzESAfig);
end

% %%
% % mpt.mat = mean(ptESAmat,3); % mean peri-trough ESA matrix across all troughs
% figure; contourf(mpt.time,1:size(mpt.mat,1),mpt.mat,100,'LineStyle','none');
% set(gca,'YDir','reverse')
% yticks(1:size(mpt.mat,1))
% yticklabels(mpt.br);
% colorbar