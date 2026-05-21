function fa = psr_Add_pvalsToFig(fa,pvals)
%% psr_Add_pvalsToFig  Adds p-values to polar plot figures
%
% INPUTS:
%   fa - structure of figures handles (output from `psr_spikePhasePref`)
%   pvals - p-values of observed vector lengths (output from `psr_phase_pvals`)
%
% OUTPUTS:
%   fa - same as input but with added p-values
%
% Written by Scott Kilianski
% Updated on 2026-04-17
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
for fii = 1:numel(fa)
    set(groot, 'CurrentFigure', fa(fii));
    strng = sprintf('p-val: %.1e', pvals(fii));
    annotation('textbox', [0.10, 0.58, 0.4, 0.21], ...  % [x y width height] in normalized units
        'String', strng, ...
        'EdgeColor', 'none', ...
        'Color', 'k',...
        'FontSize',14);
end

end % function end