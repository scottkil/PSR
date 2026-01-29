function [ttp, hlfdur] = psr_spikeFeat(cWF)
%% psr_spikeFeat Returns mean waveforms of all clusters on their best channels
%
% INPUTS:
%   cWF - current wave form. 1 x # samples vector. Usually in uV units, but not necessarily
%
% OUTPUTS:
%   ttp - trough-to-peak time (milliseconds)
%   hfldur - half-amplitude duration (milliseconds)
%
% Written by Scott Kilianski
% Updated on 2025-10-29
% ------------------------------------------------------------ %
%% Function Body %%
FS = 30000; % sampling frequency (samples/sec)
[minV, minIDX] = min(cWF);
[~, pmmIDX] = max(cWF(minIDX+1:end)); % find index to maximum value AFTER the overall minimum
pmmIDX = pmmIDX + minIDX; % adjust index to account for the offset from minIDX
ttp = 1000*(pmmIDX-minIDX)/FS; % trough-to-peak time (in ms)
vThresh = minV/2; % half-amplitude threshold
spkstrt = find(cWF<vThresh,1,'first');
spkend = find(cWF<vThresh,1,'last');

hlfdur = 1000*(spkend-spkstrt)/FS; % half-amplitude duration (ms)

%
% figure;
% plot(cWF);
% hold on
% scatter(minIDX,minV);
% scatter(pmmIDX,cWF(pmmIDX));
% hold off

end % function end
