function [ESA, timevec, convESA] = psr_calculateESA(ds, choi, plotFlag)
%% psr_calculateESA Calculate Entire Spiking Activity (ESA) across time (adapted from Drebitz et al. 2019)
%
% INPUTS:
%   ds - output of psr_downsampleRawData. structure containing downsampled data organized into the following fields:
%           - data: #Chans x #Samples (after downsampling) matrix. Stored in in16 format to reduce file size
%           - scaleFactor: multiply by ds.data to convert to microVolts
%           - fs: downsampled sampling frequency. Use (0:size(ds.data,2)-1)./ds.fs to generate time vector for ds.data (in seconds units)
%   choi - channel to use
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
chData = ds.data(choi,:);
scaleFactor = 0.195; % scale chData to microvolts
Fs = ds.fs; % Sampling frequency in Hz
Fpass = 300; % Passband edge frequency in Hz
Flow = 100;
% Rp = 0.5; % Maximum passband ripple in dB
N = 50; % Filter order
b_low = fir1(N, Fpass/(Fs/2), 'low');

% Design the high-pass FIR filter using fir1
b_high = fir1(N, Fpass/(Fs/2), 'high');
ts_filtered_high = filtfilt(b_high, 1, double(chData));
ts_filtered_low = filtfilt(b_low,1,double(chData));
% Design the low-pass equiripple FIR filter
% numFreqPoints = 2 * round(Fs / Fpass); % Ensure the number of frequency points is even
% b = firpm(N, [0, Fpass, Fpass + (Fs / 2)], [1, 1, 0, 0], [10^(Rp/20), 10^(-40/20)], [], numFreqPoints);
% b = firpm(N, [0, Fpass, Fpass+(Fs/2)], [1, 1, 0, 0], [10^(Rp/20), 10^(-40/20)]);
% b_low = fir1(N, flow/(Fs/2));
% b_low = fir1(N, 2/(Fs/2), 'low');

%%
% Apply the low-pass filter to the signal
% ESA = filtfilt(b_low, 1, abs(ts_filtered_high));
ESA = abs(ts_filtered_high);
envSize = 10; % samples?
ESAenv = envelope(ESA,envSize);

num_points = 201; % number of samples, 201 is 201ms if sampling frequency is 1kHz
sigma = 0.005; % seconds
sigmaSamp = sigma*ds.fs; % desired sigma x sampling rate
x = linspace(-(num_points-1)/2, (num_points-1)/2, num_points); % Generate the range of x values (fixed range)
gaussKern = exp(-0.5 * (x / sigmaSamp).^2); % Calculate the Gaussian kernel
gaussKern = gaussKern / sum(gaussKern); % Normalize the kernel

convESA = conv(ESA,gaussKern,'same');
smoothESA = smoothdata(ESA,1,"movmean",sigmaSamp);
timevec = (0:size(ds.data,2)-1)./ds.fs;

%%
% --- Plot original and filtered signals --- %
if plotFlag

    figure;
    ax(1) = subplot(3,1,1);
    plot(timevec, double(chData).*scaleFactor,...
        'k','LineWidth',1.5);
    title('Original Signal');
    ylabel('Amplitude');
    
    % figure;
    ax(2) = subplot(3,1,2);
    plot(timevec,ts_filtered_high,'k');
    title('High-pass filtered trace');
    ylabel('Amplitude')
    
    % figure;
    ax(3) = subplot(3,1,3);
    % barColor = [0.65, 0.65, 0.65];
    % bar(timevec,abs(ts_filtered_high),...
    %     'FaceColor',barColor,'EdgeColor',barColor);
    hold on
        plot(timevec, convESA,...
        'k','LineWidth',1.5);
    hold off
    title('Entire Spiking Activity "ESA"');
    xlabel('Time');
    ylabel('Amplitude');

    linkaxes(ax,'x');
end

end % function end