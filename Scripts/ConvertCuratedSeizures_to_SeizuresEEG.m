%%
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');

%%
for ii = 1:size(recfin,1)
    cdir = recfin.Filepath_SharkShark_{ii};
    dircon = dir(cdir);
    fnames = {dircon.name};
    fList = cellfun(@(X) contains(X,'curated'),fnames,'UniformOutput',false)';
    fLog = cell2mat(fList);
    szFile = fullfile(cdir,fnames{fLog});
    load(szFile,'seizures');
    outname = fullfile(cdir,'seizures_EEG.mat');
    save(outname,'seizures','-v7.3');
end