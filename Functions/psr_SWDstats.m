function [durs, PFs] = psr_SWDstats(topdir)
%% psr_SWDstats Computes statistics (duration, peak frequency, and power spectra) for all detected SWDs in a recording
%
% INPUTS:
%   topdir - top-level directory
%
% OUTPUTS:
%   durs - SWD durations (seconds)
%   PFs - peak frequencies (Hz)
%
% Written by Scott Kilianski
% Updated on 2026-05-02
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
seizFile = fullfile(topdir,'seizures_EEG.mat');
load(seizFile,'seizures')
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
sz = seizures(keepLog); % keep only 'good' seizures

fs = sz(1).parameters{2,5}; % sampling frequency
tic

for swdi = 1:numel(sz)
    cIDX = sz(swdi).trTimeInds(1):sz(swdi).trTimeInds(end);
    data = sz(swdi).EEG(cIDX);
    segmentLength = length(data);

    % Apply window function
    windowedData = data .* hann(segmentLength);

    % Perform FFT
    fftResult = fft(windowedData);

    % Compute power spectrum
    powerSpectrum = abs(fftResult) .^ 2;

    % Normalize PSD
    powerSpectrum = powerSpectrum / (segmentLength ^ 2);

    % Frequency axis
    freq = (0:segmentLength-1) * fs / segmentLength;

    % Limit frequency range to 9Hz (because the 2nd harmonic (11-12 Hz) often has more power)
    freqRange = freq(freq <= 9);
    powerSpectrum = powerSpectrum(1:length(freqRange));
    [~, maxI] = max(powerSpectrum);
    PFs(swdi,1) = freqRange(maxI);
    durs(swdi,1) = sz(swdi).time(cIDX(end)) - sz(swdi).time(cIDX(1)); % duration in seconds

end
toc

end % function end