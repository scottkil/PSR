%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');
%%
bigC = {};
ureqs = unique(dtbl.RecID);
for rii = 1:length(ureqs)
    subTable = dtbl(dtbl.RecID == ureqs(rii),:);
    NL = unique(subTable.SimpleName);
    for brii = 1:length(NL)
        brLog = strcmp(subTable.SimpleName,NL(brii));
        sc{2} = ureqs(rii);
        sc{1} = NL{brii};
        sc{3} = mean(subTable.SWDFR(brLog));
        sc{4} = mean(subTable.MotionFR(brLog));
        sc{5} = mean(subTable.StillFR(brLog));
        sc{6} = sum(brLog);
        bigC = [bigC;sc]; % append small cell array to big cell array
    end
end

%%
SessionStateTable = cell2table(bigC,"VariableNames",{'Region','Session','SWDFR','MotionFR','StillFR','NumNeurons'});
% writetable(stateTable, '/home/scott/Documents/PSR/Data/SessionBehaviorStateFRtable.csv');
