function md = psr_mapBinData(filename,numChans)
%% psr_mapBinData Maps data in .bin binary files using memory mapping method
%
% INPUTS:
%   filename - fulle filepath to the .bin file
%   numChans - number of channels in the .bin file (64 for 64-channel probes, 256 for 256-channel probes, typically 8 for analog data)
%
% OUTPUTS:
%   md - mapped data, a memory map objected.
%        Data is in matrix (numChans x numSamples) in md.Data.ch
%
% Written by Scott Kilianski
% Updated on 2023-11-09

%   ------------------------------------------------------------   %
%% ---- Function Body Here ---- %%%
d = memmapfile(filename,'Format','int16'); % memory map to load data
nSamps = numel(d.Data)/numChans;           % divide number of total samples (across all channels) by number of channels to find number of samples
md = memmapfile(filename,'Format',...
    {'int16',[numChans,nSamps],'ch'});      % memory map with numChans x nSamps dimensions for easier indexing

end % function end