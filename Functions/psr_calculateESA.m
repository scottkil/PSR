function [ESA, timevec] = psr_calculateESA(ds, choi, plotFlag)
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
% Updated on 2024-12-06
% ------------------------------------------------------------ %

%% ---- Function Body Below ---- %%
funClock = tic;                             % start function clock
chData = ds.data(choi,:);                   % retrieve data
timevec = (0:size(ds.data,2)-1)./ds.fs;     % make time vector
scaleFactor = ds.scaleFactor;               % scale to convert chData to microvolts
[~, b] = psr_makeFIRfilter_300to12500Hz;    % return filter coefficients for 0.3 to 12.5kHz equiripple FIR-filter (assumes 30kHz Fs)
BPdata = filtfilt(b, 1, double(chData)');   % band-pass-filtered data
BPD_rect = abs(BPdata);                     % rectify the band-pass-filtered data

% -- Prepare Gaussian Kernel for Convolution -- %
sigma = 0.005;                                                  % sigma value for Gaussian kernel convolution (in seconds)
num_points = 201*30;                                            % number of samples over which Gaussian will be convolved (201 is 201ms if sampling frequency is 1kHz)
sigmaSamp = sigma*ds.fs;                                        % desired sigma x sampling rate
x = linspace(-(num_points-1)/2, (num_points-1)/2, num_points);  % generate the range of x values
gaussKern = exp(-0.5 * (x / sigmaSamp).^2);                     % compute the Gaussian kernel
gaussKern = gaussKern / sum(gaussKern);                         % normalize the kernel

% -- Apply Convolution to Each Specified Channel -- %
for si = 1:size(BPD_rect,2)
    ESA(:,si) = conv(BPD_rect(:,si),gaussKern,'same');
end

%% --- Plot original and filtered signals --- %
if plotFlag

    figure;
    ax(1) = subplot(3,1,1);
    plot(timevec, double(chData).*scaleFactor,...
        'k','LineWidth',1.5);
    title('Original Signal');
    ylabel('Amplitude');
    
    ax(2) = subplot(3,1,2);
    plot(timevec,BPdata,'k');
    title('Band-pass filtered trace');
    ylabel('Amplitude')
    
    ax(3) = subplot(3,1,3);
    barColor = [0.65, 0.65, 0.65];
    bar(timevec,BPD_rect,...
        'FaceColor',barColor,'EdgeColor',barColor);
    yyaxis right
    hold on
        plot(timevec, ESA,...
        'k','LineWidth',1.5);
    hold off
    title('Entire Spiking Activity "ESA"');
    xlabel('Time');
    ylabel('Amplitude');

    linkaxes(ax,'x');
end

fprintf('Computing ESA took %.2f seconds\n',toc(funClock));

end % function end