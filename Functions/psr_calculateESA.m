function ESA = psr_calculateESA(chData, plotFlag)
%% psr_calculateESA Calculate Entire Spiking Activity (ESA) across time (adapted from Drebitz et al. 2019)
%
% INPUTS:
%   chData - channel data. Can be vector or matrix
%   plotFlag - 0 (default) for no plots. 1 for plots
%
% OUTPUTS:
%   ESA - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2024-08-12
% ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%
% --- Parameters for the low-pass filter --- %
Fs = EEG.finalFS; % Sampling frequency in Hz
Fpass = 300; % Passband edge frequency in Hz
% Flow = 300;
Rp = 0.5; % Maximum passband ripple in dB
N = 50; % Filter order

% Design the high-pass FIR filter using fir1
b_high = fir1(N, Fpass/(Fs/2), 'high');
ts_filtered_high = filtfilt(b_high, 1, chData);

% Design the low-pass equiripple FIR filter
% numFreqPoints = 2 * round(Fs / Fpass); % Ensure the number of frequency points is even
% b = firpm(N, [0, Fpass, Fpass + (Fs / 2)], [1, 1, 0, 0], [10^(Rp/20), 10^(-40/20)], [], numFreqPoints);
% b = firpm(N, [0, Fpass, Fpass+(Fs/2)], [1, 1, 0, 0], [10^(Rp/20), 10^(-40/20)]);
% b_low = fir1(N, flow/(Fs/2));
b_low = fir1(N, 2/(Fs/2), 'low');

% Apply the low-pass filter to the signal
ESA = filtfilt(b_low, 1, abs(ts_filtered_high));
envSize = 10; % samples?
ESAenv = envelope(ESA,envSize);
smoothESA = smoothdata(ESA,1,"movmean",100);

% --- Plot original and filtered signals --- %
if plotFlag
    figure;
    ax(1) = subplot(3,1,1);
    plot(EEG.time, EEG.data,...
        'k','LineWidth',1.5);
    title('Original Signal');
    xlabel('Time');
    ylabel('Amplitude');

    ax(2) = subplot(3,1,2);
    plot(EEG.time, smoothESA,...
        'k','LineWidth',1.5);
    title('Entire Spiking Activity "ESA"');
    xlabel('Time');
    ylabel('Amplitude');

    ax(3) = subplot(3,1,3);
    plot(TTL.time, TTL.data,...
        'k','LineWidth',1.5);
    title('TTL');
    xlabel('Time');
    ylabel('Amplitude');

    linkaxes(ax,'x');
end

end % function end