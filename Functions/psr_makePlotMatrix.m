function outMat = psr_makePlotMatrix(inMat,smoothwin)
%% psr_makePlotMatrix Smoothes and normalizes inMat for plotting purposes
%
% INPUTS:
%   inMat - Input matrix
%   smoothwin - smoothing window (in samples). Always operates across columns (i.e. Dim2 of inMat)
%
% OUTPUTS:
%   outMat - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2026-04-24
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
mptp = smoothdata(inMat,2,"gaussian",smoothwin);
repMat = repmat(max(mptp,[],2),1,size(mptp,2));
outMat = mptp./repMat;

end % function end