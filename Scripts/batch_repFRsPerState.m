%%
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');
%%
bigC = {};
ureqs = unique(dtbl.RecID);
for rii = 1:1%length(ureqs)
    subTable = dtbl(dtbl.RecID == ureqs(rii),:);
    NL = unique(subTable.SimpleName);
    for brii = 1:length(NL)
        brLog = strcmp(subTable.SimpleName,NL(brii));
        sc{1} = NL{brii};
        sc{2} = mean(subTable.SWDFR(brLog));
        sc{3} = mean(subTable.MotionFR(brLog));
        sc{4} = mean(subTable.StillFR(brLog));
        bigC = [bigC;sc]; % append small cell array to big cell array
    end


    smallMat = repmat({dtbl.SimpleName{nii},...
        dtbl.Subject_(nii),...
        dtbl.RecID(nii),...
        dtbl.UniqueNeuron_(nii)},...
        3,1);
    smallMat{1,6} = dtbl.SWDFR(nii);    smallMat{1,5} = 'SWD';
    smallMat{2,6} = dtbl.StillFR(nii);  smallMat{2,5} = 'Still';
    smallMat{3,6} = dtbl.MotionFR(nii); smallMat{3,5} = 'Moving';
    bigTable = [bigTable; smallMat];
end

%%
stateTable = cell2table(bigTable,"VariableNames",{'Region','Subject','Session','Neuron','State','FR'});
writetable(stateTable, '/home/scott/Documents/PSR/Data/BehaviorStateFRtable.csv');
