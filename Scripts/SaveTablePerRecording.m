%%
csvin = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv','Delimiter',',');
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv','Delimiter',',');
FPs = recfin.Filepath_SharkShark_;
recIDs = csvin.RecID;
urecs = unique(recIDs);

%%
for ri = 1:numel(urecs)
    matchLog = recIDs == urecs(ri);
    cTable = csvin(matchLog,:);
    cfn = sprintf('%sCellInfo.csv',FPs{ri});
    writetable(cTable,cfn,'Delimiter',',');
end