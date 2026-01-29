%%
% This is where I define the channel indices
linChIDX = [97;33;98;34;99;35;100;36;101;37;102;38;103;39;104;40;105;41;106;42;107;43;108;44;109;45;110;46;111;47;112;48;49;19;83;22;86;25;89;28;92;31];

%%
read_Intan_RHD2000_file;
linda = amplifier_data(linChIDX,:);

%% Compute FFTs
% Example: Time-domain signal
fs = 30000;              % Sampling frequency (Hz)
t = t_amplifier;       % Time vector (1 second duration)
signal = linda'; % Signal with two frequencies

%% Compute FFT
N = size(signal,1);                     % Number of samples
fftSignal = fft(signal,[],2);           % Compute FFT
P2 = abs(fftSignal/N).^2;               % Two-sided power spectrum
P1 = P2(1:N/2+1,:);                     % Single-sided spectrum
P1(2:end-1) = 2*P1(2:end-1);            % Double amplitudes (except DC and Nyquist)

% Frequency vector
frequencies = fs*(0:(N/2))/N;
%
% Plot Power Spectral Density
figure;
plot(frequencies, P1(:,1));
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('Power Spectral Density');
% grid on;

%%
freqLog = (frequencies<=150 & frequencies >= 1);
keepFreqs = frequencies(freqLog);
P150 = P1(freqLog,:);
MaxPower= max(P150,[],2);
mpMat = repmat(MaxPower,[1,42]);
P150R = P150./mpMat;


%%
figure;
imagesc(keepFreqs,1:42,P150R');
