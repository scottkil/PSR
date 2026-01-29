function psr_makeESA(filename)
%% psr_makeESA Makes ESA file for all channels in combined.bin file
%
% INPUTS:
%   filename - full filepath to a combined.bin file
%
% OUTPUTS:
%   NONE - the ESA vectors are saved in
%
% Written by Scott Kilianski
% Updated on 2025-11-01
% ------------------------------------------------------------ %
%% === Function Body Here === %%

% --- Assign several static variables --- %
origFS = 30000;      % original sampling frequency (30kHz usually)
numChans = 256;      % number of channels on probe
scaleFactor = 0.195; % scale to convert chData to microvolts
dsFactor = 30;       % downsample factor (origFS/dsFactor gives you final FS)
sigma = 0.005;       % sigma value for Gaussian kernel convolution (in seconds)
convWin = 0.201;     % duration of convolution window (in seconds)

% --- Set up folder for storing outputs --- %
topDir = fileparts(filename);
ESAdir = fullfile(topDir,'ESA/');
if ~exist(ESAdir,"dir")
    mkdir(ESAdir); % make ESA directory if it doesn't already exist
end


% --- Set up high-pass filter to use below --- %
HP = 300;       % high-pass filter frequency (Hz)
Wn = HP / (origFS/2);     % normalize by Nyquist
[b,a] = butter(4, Wn, 'high');  % 4th order high-pass
% [~, b] = psr_makeFIRfilter_300to12500Hz;    % return filter coefficients for 0.3 to 12.5kHz equiripple FIR-filter (assumes 30kHz Fs)

% --- Memory map to find number of samples in file --- %
d = memmapfile(filename,'Format','int16'); % memory map to find data length
nSamps = numel(d.Data)/numChans;
clear d

% --- Prepare Gaussian Kernel for Convolution --- %
num_points = convWin*origFS;                % number of samples over which Gaussian will be convolved (201 is 201ms if sampling frequency is 1kHz)
sigmaSamp = sigma*origFS;                   % desired sigma x sampling rate
x = linspace(-(num_points-1)/2,...
    (num_points-1)/2, num_points);          % generate the range of x values
gaussKern = exp(-0.5 * (x / sigmaSamp).^2); % compute the Gaussian kernel
gaussKern = gaussKern / sum(gaussKern);     % normalize the kernel

% --- Read the data into RAM with proper shape (numChans x nSamps) --- %
fprintf('Loading in combined.bin...\n')
fID = fopen(filename);
tic
d = fread(fID,[numChans, nSamps],'int16=>int16');
fclose(fID);
toc

%% === Main Loop === %%
% --- Generate the ESA vector for every channel and save it --- %
tic
for chii = 1:size(d,1)
    chData = double(d(chii,:))*scaleFactor;  % retrieve current channel data and scale to uV units


    BPdata = filtfilt(b, a, chData); % band-pass filter data
    BPdata = abs(BPdata);            % rectify the band-pass-filtered data
    ESA = conv(BPdata,gaussKern,'same'); % apply convolution

    fname_ESA = sprintf('%sCh%d.bin',ESAdir,chii-1);

    cfID = fopen(fname_ESA,"w");
    fwrite(cfID,ESA(1:dsFactor:end),"double"); % save the ESA
    fclose(cfID);
    toc

end % main loop end

% --- Save the corresponding time vector --- %
timevec = (0:double(nSamps)-1)./origFS;     % make time vector
fname_timevec = sprintf('%stimevec.bin',ESAdir);
cfID = fopen(fname_timevec,"w");
fwrite(cfID,timevec(1:dsFactor:end),'double'); % save downsampled time vector
fclose(cfID);

end  % function end



