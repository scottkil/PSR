%%
load('/home/scott/Documents/PSR/Data/pethCenterOfMassTable.mat','pethCOMtable');
uRecs = unique(pethCOMtable.RecID);
bigS = {}; bigV = {}; % intialize storage matrices
pethCOMtable.CenterOfMass = pethCOMtable.CenterOfMass + max(abs(pethCOMtable.CenterOfMass)); % setting all values to >=0 to make subtraction easier below
for rii = 1:numel(uRecs)
    crLog = pethCOMtable.RecID == uRecs(rii); % current recording logical
    cTable = pethCOMtable(crLog,:);
    sLog = strcmp(cTable.SimpleName,'Somatosensory');
    vLog = strcmp(cTable.SimpleName,'Visual');
    numS = sum(sLog);
    numV = sum(vLog);
    if numS > 1 % if there are neurons from multiple layers
        cTable = cTable(sLog,:);
        for cii = 1:(numS-1) % unique combinations of pairs
            for k = (cii+1):numS
                comDiff = cTable.CenterOfMass(k) - cTable.CenterOfMass(cii);
                compName = sprintf('%d-%d',cTable.CorticalLayer(k),cTable.CorticalLayer(cii));
                bigS = [bigS; compName, {comDiff}];
            end
        end

    elseif sum(vLog) > 1
        cTable = cTable(vLog,:);
        for cii = 1:(numV-1)
            for k = (cii+1):numV
                comDiff = cTable.CenterOfMass(k) - cTable.CenterOfMass(cii);
                compName = sprintf('%d-%d',cTable.CorticalLayer(k),cTable.CorticalLayer(cii));
                bigV = [bigV; compName, {comDiff}];
            end
        end
    end

end

%% === Get all Center-of-Mass times across layers == %%
load('/home/scott/Documents/PSR/Data/pethCenterOfMassTable.mat','pethCOMtable');
xLog = strcmp(pethCOMtable.SimpleName,'Somatosensory') & pethCOMtable.CorticalLayer~= 0;

bigCOMS = [pethCOMtable.CorticalLayer(xLog), pethCOMtable.CenterOfMass(xLog), pethCOMtable.NumNeurons(xLog)];
