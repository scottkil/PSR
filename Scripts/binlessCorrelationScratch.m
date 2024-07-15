%% Generate Gaussian Kernel
% Define parameters
FS = 30000;
dsFactor = 30; 
dsFS = FS/dsFactor;
num_points = 201; % number of samples, 210 is 201ms
sigma = 0.029; % seconds
sigmaSamp = sigma*dsFS; % desired sigma x sampling rate

x = linspace(-(num_points-1)/2, (num_points-1)/2, num_points); % Generate the range of x values (fixed range)

gaussKern = exp(-0.5 * (x / sigmaSamp).^2); % Calculate the Gaussian kernel

gaussKern = gaussKern / sum(gaussKern); % Normalize the kernel

% figure;
% plot(x,gaussKern);


%% --- Get spike times and timestamps --- %%
xdir = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
spikeArray = psr_makeSpikeArray(xdir); % have to make spikeArray TS (indices) not seconds!!!!
TSID = fopen(fullfile(xdir,'timestamps.bin'));
TS = fread(TSID,'int32');
fclose(TSID);
dsTIMES = [TS(1):dsFactor:TS(end)]/FS';

%%
% -- Downsample to 1Khz -- %
% -- Assign spikes to nearest downsampled time point -- %
fprintf('Assigning spikes to nearest downsampled point...\n');
interpFun = @(A) interp1(dsTIMES,dsTIMES,A,'nearest','extrap');
dsSpikes = cellfun(interpFun,spikeArray,'UniformOutput',false);
numCells = numel(spikeArray);

%%
for k = 1:numCells
    est = zeros(length(dsTIMES),1);
    est(round(dsSpikes{k}*dsFS)) = 1;
    conv_est(:,k) = conv(est,gaussKern,'same'); % Gaussian smooth the spike trains 
end

%%
% cc = corrcoef(conv_est);
spkTotMat = repmat(sum(conv_est,1),length(dsTIMES),1);
normEST = conv_est./spkTotMat;
for k = 1:numCells
    for n = 1:numCells
        zzz(k,n) = trapz(sqrt(normEST(:,k) .* normEST(:,n))); % THEN TAKE THE INTEGRAL OF THE PRODUCT OF TWO SMOOTHED SPIKE TRAINS
    end
end

%%
indMat = triu(true(size(zzz)),1);
figure;
subplot(211);
imagesc(zzz);
clim([0 1]);
subplot(212);
histogram(zzz(indMat))
% THEN TAKE THE INTEGRAL OF THE PRODUCT OF TWO SMOOTHED SPIKE TRAINS
% www(k,n) = cc(2);
%%
% for k = 1
%     for n = 1:10
%         fprintf('Cell %d vs %d\n',k,n)
% % k = 2;
% % est = zeros(length(TS),2);
% est = zeros(length(dsTIMES),2);
% ST1 = interp1(dsTIMES, dsTIMES, spikeArray{k},'nearest','extrap');
% ST2 = interp1(dsTIMES, dsTIMES, spikeArray{n},'nearest','extrap');
% 
% est(round(ST1*dsFS),1) = 1;
% est(round(ST2*dsFS),2) = 1;
% 
% % CONVOLVE est WITH THE GAUSSIAN KERNEL 
% conv_est1 = conv(est(:,1),gaussKern,'same');
% conv_est2 = conv(est(:,2),gaussKern,'same');
% 
% % BLcorr(k) = trapz(conv_est1 .* conv_est2);
% 
% aaa = conv_est1/sum(conv_est1);
% bbb = conv_est2/sum(conv_est2);
% zzz(k,n) = trapz(sqrt(aaa .* bbb)); % THEN TAKE THE INTEGRAL OF THE PRODUCT OF TWO SMOOTHED SPIKE TRAINS
% % totalNumSpikes = length(ST1)+length(ST2);
% % ddd(k,n) = sum(conv_est1-conv_est2)/sum(totalNumSpikes);
% cc = corrcoef(conv_est1,conv_est2);
% www(k,n) = cc(2);
% % From Kruskal et al. 2007 
% % sInd = ; % start index
% % eInd = ; % end index
% % T = TS(end)/30000;
% % % sd = 0.029;
% % % ST1 = spikeArray{1};
% % % ST2 = spikeArray{9};
% % % Find the number of spikes per train:
% % N1 = length(ST1);
% % N2 = length(ST2);
% % 
% % % Calculate convolution integrals:
% % CovG = 0; % Gaussian-smoothed covariance
% % for i = 1:N1 
% % for j = 1:N2
% %     if abs(ST1(i)- ST2(j)) < 6*sigma
% %         CovG = CovG + exp( (ST1(i)-ST2(j))^2 / (-4*sigma^2) );
% %     end
% % end
% % end
% % 
% % % Normalize integral and subtract firing rate term:
% % CovGk(k) = CovG/(2*sigma*sqrt(pi)*T) - N1*N2/T^2;
%     end
% end