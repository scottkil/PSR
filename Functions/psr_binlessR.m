function [blCorrs, pCorrs] = psr_binlessR()
%% psr_binlessR Computes Pearson's correlations coefficients and a 'binless' correlation measure of spikes trains
% See Krusakl et al. (2007) for more info about binless correlations
% INPUTS:
%
%
% OUTPUTS:
%   output1 - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2024-07-12
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
FS = 30000;         % sampling frequency
dsFactor = 30;      % downsampling factor (downsampling to 1000Hz is usually a good idea)
gaussWin = 0.201;   % in sec. Time window over which to evaluate the Gaussian convolution
dsFS = FS/dsFactor; % downsampled sampling frequency

% -- Construct Gaussian kernel for smoothing later -- %
num_points = round(gaussWin*dsFS);  % number of samples
sigma = 0.029;                      % in seconds. Sigma determines the width of the Gaussian kernel
sigmaSamp = sigma*dsFS;             % converting sigma to # of samples
x = linspace(-(num_points-1)/2, (num_points-1)/2, num_points); % generate the range of x values (fixed range)
gaussKern = exp(-0.5 * (x / sigmaSamp).^2); % calculate the Gaussian kernel
gaussKern = gaussKern / sum(gaussKern);     % normalize the kernel

%%
% -- Get spike times and timestamps -- %
% fprintf('Retrieving spi...\n');
xdir = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
spikeArray = psr_makeSpikeArray(xdir); % have to make spikeArray TS (indices) not seconds!!!!
dt = 0.001; % seconds (time step for Q matrix)
timeLims = [0 max(cellfun(@max,spikeArray))];
[Q, timeVec] = psr_makeQ(spikeArray,timeLims, dt, dt);
spkMat = round(Q.*dt)'; % convert Q matrix (firing rate) back to binned spike matrix (spike count units)
% TSID = fopen(fullfile(xdir,'timestamps.bin'));
% TS = fread(TSID,'int32');
% fclose(TSID);
% dsTIMES = [TS(1):dsFactor:TS(end)]/FS';

% -- Assign spikes to nearest downsampled time point -- %
% interpFun = @(A) interp1(dsTIMES,dsTIMES,A,'nearest','extrap'); % function to assign spikes to nearest downsampled time
% dsSpikes = cellfun(interpFun,spikeArray,'UniformOutput',false); % apply that function
%%
% -- Convolve spike trains with Gaussian kernel -- %
fprintf('Convolving spike trains with Gaussian kernel...\n');
numCells = numel(spikeArray);
for k = 1:numCells
    conv_spkMat(:,k) = conv(spkMat(:,k),gaussKern,'same');
end

%%
% -- Do correlation procedures
fprintf('Calculating correlations...\n');
spkTotMat = repmat(sum(conv_spkMat,1),length(timeVec),1);
normEST = conv_spkMat./spkTotMat;

% -- Perform 'binless' correlation (element-wise product of spike trains) -- %
for k = 1:numCells
    fprintf('Neuron %d complete.\n',k);
    for n = 1:numCells
        emptyLog = normEST(:,k) == 0 & normEST(:,n) == 0;       % logical with find zeros
        blCorrs(k,n) = trapz(sqrt(normEST(:,k) .* normEST(:,n)));   % take integral of element-wise product of spike trains

        [R,P,RL,RU] = corrcoef(normEST(~emptyLog,k), normEST(~emptyLog,n)); % spike train correlation stats (correlations of time steps when at least 1 neuron is active)
        pCorrs.R(k,n) = R(2);
        pCorrs.P(k,n) = P(2);
        pCorrs.RL(k,n) = RL(2);
        pCorrs.RU(k,n) = RU(2);
    end
end

% % -- Actual correlation of spike trains -- %
% if 2
%     for k = 1:numCells
%         for n = 1:numCells
% 
%             zzz(k,n) = trapz(sqrt(normEST(:,k) .* normEST(:,n))); % take integral of element-wise product of spike trains
%         end
%     end
% end
%% Needs update
indMat = triu(true(size(blCorrs)),1);
% figure;
% subplot(211);
% imagesc(blCorrs);
% clim([0 1]);
% subplot(212);
% histogram(blCorrs(indMat))

end % function end