function [rms_uV, nSamplesPerChan] = rms_hp_stream(binFile, nChan, fs, hpHz, gain_uV, chunkDurSec)
% Streamed RMS after high-pass filtering (default 300 Hz) for interleaved int16
% Layout: [ch1..ch256] sample1, then [ch1..ch256] sample2, ...
% Returns per-channel RMS in microvolts.

if nargin < 3 || isempty(fs), fs = 30000; end
if nargin < 4 || isempty(hpHz), hpHz = 300; end
if nargin < 5 || isempty(gain_uV), gain_uV = 0.195; end
if nargin < 6 || isempty(chunkDurSec), chunkDurSec = 10; end

bytesPerSample = 2;                 % int16
fileInfo = dir(binFile);
totalFrames = fileInfo.bytes / (nChan*bytesPerSample);  % number of time samples
assert(mod(totalFrames,1)==0, 'File size not divisible by nChan*2 bytes.');

% --------- High-pass filter (SOS IIR, stable, small state) ----------
% 8th-order Butterworth HP (zero-phase not required for RMS).
[b,a] = butter(4, hpHz/(fs/2), 'high');
[sos,g] = tf2sos(b,a);
nSec = size(sos,1);
% Keep independent states per channel
zi = zeros(nChan, 2*nSec);          % Direct Form II Transposed needs 2 states per section

% --------- Streaming control ----------
chunkFrames = max(1, round(fs*chunkDurSec));     % time samples per chunk
nChunks = ceil(totalFrames / chunkFrames);

% Running accumulators in double for numerical safety
sumSq = zeros(1, nChan, 'double');
nSamplesPerChan = 0;                 % grow as we process
fid = fopen(binFile, 'r');

% Optional: overlap-save to reduce initial transients
% A small overlap (e.g., 2x filter order) is enough for RMS
overlap = max(64, 6*max(length(a), length(b)));  % ~transient length
prevTail = [];

for k = 1:nChunks
    % --- Read chunk as [nChan x chunkFrames] single; leave interleaving to fread ---
    framesToRead = min(chunkFrames, totalFrames - (k-1)*chunkFrames);
    raw = fread(fid, [nChan, framesToRead], 'int16=>single');
    if isempty(raw), break; end

    % Optional overlap padding (per channel)
    if ~isempty(prevTail)
        x = [prevTail, raw]; % [nChan x (overlap+framesToRead)]
    else
        x = raw;
    end

    % --- Filter each channel with persistent states ---
    % Apply SOS section-by-section with state carried across chunks.
    % Vectorized biquad pass:
    y = x;
    for s = 1:nSec
        % Extract section
        b0 = sos(s,1); b1 = sos(s,2); b2 = sos(s,3);
        a0 = sos(s,4); a1 = sos(s,5); a2 = sos(s,6);
        % Direct Form II Transposed
        % States for this section, per channel:
        w1 = zi(:, 2*s-1);
        w2 = zi(:, 2*s);

        % Process along time (vectorized over channels)
        for t = 1:size(y,2)
            xt   = y(:,t);
            wt   = xt - a1*w1 - a2*w2;
            yt   = g*(b0*wt + b1*w1 + b2*w2);
            y(:,t) = yt;
            % update states
            w2 = w1;
            w1 = wt;
        end
        zi(:, 2*s-1) = w1;
        zi(:, 2*s)   = w2;
    end

    % Drop overlap from the front (ignore its contribution to RMS)
    if ~isempty(prevTail)
        y = y(:, (overlap+1):end);
    end

    % Update prevTail for next chunk (copy last "overlap" samples unfiltered-input wise)
    if size(raw,2) >= overlap
        prevTail = raw(:, end-overlap+1:end);
    else
        prevTail = raw(:, end-min(end,overlap)+1:end);
    end

    % --- Accumulate RMS on this filtered chunk (still in ADC units) ---
    % Use double for accumulator; y is single
    sumSq = sumSq + sum(double(y).^2, 2).';  % row vector
    nSamplesPerChan = nSamplesPerChan + size(y,2);
end

fclose(fid);

rms_adc = sqrt(sumSq ./ max(1,nSamplesPerChan));  % ADC units (int16 LSBs)
rms_uV  = rms_adc * gain_uV;                      % convert once at the end
end
