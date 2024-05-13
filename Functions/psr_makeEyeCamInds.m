function eyeCamInds = psr_makeEyeCamInds(ffn)
%% psr_makeEyeCamInds Template for a custom function
%
% INPUTS:
%   ffn - full filename to the analogData.bin file
%   ***This function assumes the camera TTL is channel 8 in the
%   analogData.bin file***
%
% OUTPUTS:
%   eyeCamInds - indices to the camera frame times. Should be equal to # of
%   eye camera frames
%
% Written by Scott Kilianski
% Updated on 2024-03-21
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%
% ffn = 'X:\PSR_Data\PSR_21\PSR_21_Rec3_231020_115805\analogData.bin';  % full filename
numChans = 8; % number of channels on the probe used to record
ad = memmapfile(ffn,'Format','int16');  % memory map to load data
nSamps = numel(ad.Data)/numChans; % divide number of total samples (across all channels) by number of channels to find number of samples
ad = memmapfile(ffn,'Format',{'int16',[numChans,nSamps],'ch'}); % memory map with numChans x nSamps dimensions for easier indexing
camTTLthresh = 5000; % threshold for camera TTL
eyeCamInds = find(diff(ad.Data.ch(8,:)>camTTLthresh)==1);

end % function end