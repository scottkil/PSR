%% Downsample all raw data and save in their home directories as .mat files
dirList{1} = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
dirList{2} = 'Y:\PSR_Data\PSR_17\PSR_17_Rec2_231012_124907';
dirList{3} = 'Y:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805';
dirList{4} = 'Y:\PSR_Data\PSR_25\PSR_25_Rec2_First35min';

dirList{5} ='Y:\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634';
dirList{6} ='Y:\PSR_Data\PSR_18\PSR_18_Rec2_231016_190216';
dirList{7} ='Y:\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639';
dirList{8} ='Y:\PSR_Data\PSR_22_Day1\PSR_22_Rec2_231215_113847';
dirList{9} ='Y:\PSR_Data\PSR_23\PSR_23_Rec2_231213_153523';
dirList{10} ='Y:\PSR_Data\PSR_24\PSR_24_Rec2_231208_162349';

dsFS = 1000;

%%
for di = 5:numel(dirList)
    fname = sprintf('%s%s',dirList{di},'\combined.bin');
    psr_downsampleRawData(fname,dsFS)
end