function CSD = psr_CSD(topdir)
%% psr_CSD Generates current source density matrices for each shank separately
%          Works on evenly spaced center electrodes
%          Performs CSD via 3-point estimation with Savitzky-Golay filter
%
% INPUTS:
%   topdir - top-level directory
%
% OUTPUTS:
%   CSD - structure with the following fields:
%         - meanCSD: m x n x 2 matrix. 
%           - Dim1 is electrodes (vertically arranged) 
%           - Dim2 is time points (same numel as CSD.time)
%           - Dim3 is shank (1 is shank 1, more lateral. Shank 2 is medial)
%         - chidx: same number of rows as CSD. Each column is separate shank
%         - time: time (in seconds) corresponding to columns in CSD.meanCSD
%
% Written by Scott Kilianski
% Updated on 2026-05-09
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
ufc = 100; % Upper cutoff frequency in Hz
lfc = 2; % low cutoff frequency in Hz

fprintf('Loading downsampled LFP data...\n')
load(fullfile(topdir,'downsampled.mat'),'ds'); % load downsampled LFP data
fs = ds.fs;
tv = ((1:size(ds.data,2))-1)/fs; % time vector

[b, a] = butter(4, [lfc,ufc] / (fs / 2), 'bandpass'); % 4th order bandpass Butterworth filter
scaleFactor = ds.scaleFactor * 1e-6;   % factor used to convert amplifier_data unit to VOLTS (0.195 from Intan)
shankName = {'Lateral Shank';...
    'Medial Shank'};
TT = psr_getTroughTimes(fullfile(topdir,'seizures_EEG.mat'));

% -- s-golay CSD estimate --- %
sgo = 2;              % quadratic local polynomial
sgolayFrame = 7;      % 9 channels, spanning 300 µm at 50 µm spacing
[~, g] = sgolay(sgo, sgolayFrame);
halfWin = (sgolayFrame - 1) / 2; % sgolay convolution window

smWin = 5;   % number of channels in Gaussian smoothing window
ptWin = 0.1; % seconds
ptHalfWin = ds.fs*ptWin/2;

for sii = 1:2 % loop for each shank
    load(sprintf('Shank%d_CSDchans.mat',sii),'ch');
    dsData = ds.data(ch.idx,:); % current shank channel indices (vertically arranged and uniform spacing)
    dz = ch.z; % delta z (microns)
    fprintf('Filtering LFP data...\n')
    FT = filtfilt(b,a,double(dsData)'.*scaleFactor)'; % filtered traces
    smTraces = smoothdata(FT, 1, 'gaussian', smWin); % vertically smoothed

    % --- Perform the CSD via 3-point estimation with Savitzky-Golay filter --- %
    d2V = conv2(smTraces, g(:,3), 'valid') * factorial(2) / dz^2;
    wholeCSD = -d2V;

    ptCSD = [];
    for tii = 1:numel(TT)
        % --- Find samples with closest time in CSD --- %
        [~, cidx] = min(abs(tv - TT(tii))); % Find closest sample index to trough time
        cwin = (cidx-ptHalfWin):(cidx+ptHalfWin);
        ptCSD(:, :, tii) = wholeCSD(:,cwin);
    end
    meanCSD(:,:,sii) = mean(ptCSD,3);
    chI_mod(:,sii) = ch.idx((1+halfWin):(end-halfWin));
end
% --- Output structure --- %
CSD.meanCSD = meanCSD;
CSD.chidx = chI_mod;
CSD.time = (-ptHalfWin:ptHalfWin)/ds.fs; % time for CSD matrix (seconds)

end % function end

%%
% ptTime = (-ptHalfWin:ptHalfWin)/ds.fs;
% 
% yd = 1:numel(chI_mod);
% 
% figure;
% imagesc(ptTime, yd, meanCSD(:,:,2));
% yticks(yd)
% % yticklabels(electrodeLocations(chI_mod,2));
% colormap(jet)
