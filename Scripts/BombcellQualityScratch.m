%%
clear all; close all
% topdir = 'Y:\PSR_Data\PSR_25\PSR_25_Rec2_First35min\';
topdir = uigetdir;
% bombFun(topdir);

%
cifile = fullfile(topdir, 'cluster_info.tsv');                  % set cluster_info file path
ci = readtable(cifile, "FileType","text",'Delimiter', '\t');    % load cluster information (Phy output)
tsvpath = fullfile(topdir,'\bombcell\templates._bc_unit_labels.tsv');           % set bombcell cluster info file path
bc_lab = table2array(readtable(tsvpath, "FileType","text",'Delimiter', '\t'));  % load bombcell labels

phygood = strcmp(ci.group,'good');
bcgood = bc_lab == 1;
ovlap = phygood & bcgood;
fprintf('%s\n',topdir);
fprintf('Phy: %d\n',sum(phygood))
fprintf('Bombcell: %d\n',sum(bcgood))
fprintf('Overlap: %d\n',sum(ovlap))
