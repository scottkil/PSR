%%
csvin = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv','Delimiter',',');
cvsName = readtable('/home/scott/Documents/PSR/Data/NameMappingList.csv','Delimiter',',');
simpName = cvsName.SimplifiedName;
simpLayer = cvsName.Layer;
allenName = cvsName.AllenAtlasName;
aaname = csvin.AllenAreaName;

%% 
for ii = 1:numel(aaname)
    matchLog = strcmp(aaname{ii}, allenName); % every entry (single neuron) should have exactly one matching structure
    newStr(ii,1) = simpName(matchLog);
    newLayer(ii,1) = simpLayer(matchLog);
end
