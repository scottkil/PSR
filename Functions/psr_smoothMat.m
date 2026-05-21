function outMat = psr_smoothMat(inMat,x_sw,y_sw,xint,yint)
%% psr_smoothMat Smooths input matrix and upsamples between points 
%
% INPUTS:
%   inMat - input matrix
%   x_sw - x smoothing window
%   y_sw - y smoothing window
%   xint - x upsampling factor
%   yint - y upsampling factor
%
% OUTPUTS:
%   outMat - smoothed and upsampled matrix
%
% Written by Scott Kilianski
% Updated on 2026-04-22
% ------------------------------------------------------------ %
%% === Function body here === %%
smMat = smoothdata(inMat,1,'gaussian',y_sw); % smooth vertically
smMat = smoothdata(smMat,2,'gaussian',x_sw); % smooth horizontally
[nR, nC] = size(smMat); % set original grid coordinates
[x, y] = meshgrid(1:nC, 1:nR); % build original mesh grid
[xq, yq] = meshgrid( ...
    linspace(1, nC, nC*xint), ...
    linspace(1, nR, nR*yint) ); % new upsampled grid
outMat = interp2(x, y, smMat, xq, yq, 'spline');

end % function end