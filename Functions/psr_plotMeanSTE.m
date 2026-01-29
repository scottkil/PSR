function psr_plotMeanSTE(ax,xd,yd,stOption)
%% psr_plotMeanSTE 
%
% INPUTS:
%   ax - axes on which to plot
%   xd - x data. isequal(length(xd),size(ydata,2)) must be TRUE
%   yd - y data (matrix). Each column will be average. Final result is 1d vector with length()==size(ydata,2)
%   stOption - 'std' for standard deviation or 'ste' for standard error of the mean
%
% OUTPUTS:
%   output1 - Description of output variable
%
% Written by Scott Kilianski
% Updated on 2023-11-09
% % ------------------------------------------------------------ %

%% ---- Function Body Here ---- %%%
if ~exist('stOption','var')
    stOption = 'std';
end

ym = nanmean(yd,1); %y points (means)
if strcmp(stOption,'std')
    ys = nanstd(yd,1);                          % y standard deviation
elseif strcmp(stOption,'ste')
    ys = nanstd(yd,1)./sqrt(sum(~isnan(yd)));   % y standard error
else
    error(sprintf('You specificied ''%s'' as the option. Please use either ''std'' or ''ste'' as option',stOption));
end
yp = [ys+ym, fliplr(-ys+ym)];
xp = [xd,fliplr(xd)];

%Plotting
axes(ax);
hold on
patch(xp,yp,'k','FaceAlpha',0.15,'EdgeColor','none');
plot(xd,ym,'k','linewidth',1);
hold off

end % function end