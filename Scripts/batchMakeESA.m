%%
clear all; close all; clc
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
pn = recfin.Filepath_SharkShark_;

%%
outStatus = false(numel(pn),1);
for dii = 1:numel(pn)
    fprintf('%%=== Recording %d.%d ===%% \n',recfin.Subject_(dii),recfin.Recording_(dii))
    cf = sprintf('%scombined.bin',pn{dii});
    try
        psr_makeESA(cf);
        outStatus(dii) = true; % Update status to true if processing is successful
    catch
        outStatus(dii) = false; % Update status to false if an error occurs
    end
end
