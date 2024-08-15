%%
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
seizures(~keepLog) = [];
SWDlabel = false(size(timevec));
for szi = 1:numel(seizures)
    % StEnd = [seizures(szi).time(1),seizures(szi).time(end)];
    sti = find(timevec>=seizures(szi).time(1),1,'first');
    endi = find(timevec<=seizures(szi).time(end),1,'last');
    SWDlabel(sti:endi) = true;
end
SWDinds = find(SWDlabel);

%%
[pks, pkInds] = findpeaks(convESA);
pkTimes = timevec(pkInds);
zThresh = 3;
ppi = find(zscore(pks)>zThresh);
pkTimes = timevec(pkInds(ppi));
pkVals = convESA(pkInds(ppi));

%% 
figure; 
sax(1) = subplot(3,1,1);
plot(timevec,chData);

sax(2) = subplot(3,1,2);
plot(dsTime,zscore(abs(ds_filtered_signal)));

sax(3) = subplot(3,1,3);
plot(dsTime,zscore(abs(dsData_filtered)));

linkaxes(sax,'x');