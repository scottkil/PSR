function ESA = psr_getESAvert(topdir,shanknum)
%% psr_getESAvert Returns vertically ordered ESA data for one shank
%
% INPUTS:
%   topdir - path to top-level directory with recording data
%   shanknum - shank number (either 1 or 2) for 256 UCLA probe
%
% OUTPUTS:
%   ESA - structure with following fields:
%          - mat: matrix with ESA data (# channels x time)
%          - time: corresponding time vector (in seconds)
%
% Written by Scott Kilianski
% Updated on 2025-11-03
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% === Read in data === %
tic
load("MidVertChans.mat",'midVert1','midVert2'); % load the vertically ordered channel #s

ESA.mat = [];
switch shanknum
    case 1
        midVert = midVert1; % midVert1 or 2
    case 2
        midVert = midVert2; % midVert1 or 2
end
ESAdir = sprintf('%s%s',topdir,'ESA/');
for eii = 1:length(midVert)
    fp = sprintf('%sCh%d.bin',...
        ESAdir,midVert(eii));              % make the current filepath string
    cfID = fopen(fp);               % open the file
    ESA.mat(eii,:) = fread(cfID,...
        inf,'double=>double');      % read the data
    fclose(cfID);                   % close the file
end

%%
fp = sprintf('%stimevec.bin',...
    ESAdir);              % make the current filepath string
cfID = fopen(fp);               % open the file
ESA.time = fread(cfID,...
    inf,'double=>double');      % read the data
fclose(cfID);                   % close the file

toc
end % function end