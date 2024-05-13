function output1 = psr_grabSeizLFPs(varargin)
%% psr_grabSeizLFPs Retrieves seizure LFPs
%
% INPUTS:
%   
%
% OUTPUTS:
%   output1 - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2023-12-18
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
ffn = 'Y:\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639\combined.bin';  % full filename
numChans = 256; % number of channels on the probe used to record
ad = memmapfile(ffn,'Format','int16');  % memory map to load data
nSamps = numel(ad.Data)/numChans; % divide number of total samples (across all channels) by number of channels to find number of samples
ad = memmapfile(ffn,'Format',{'int16',[numChans,nSamps],'ch'}); % memory map with numChans x nSamps dimensions for easier indexing

%% Now that I have map, just get relevant samples
sampList{1} = 3000000:3090001;
tv = sampList{1}/30000;
for si = 1:numel(sampList)
    seiz{si} = ad.Data.ch(:,sampList{si});
end

end % function end