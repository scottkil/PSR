function colorList = psr_assignColors(simpName)
%% psr_assignColors Template for functions 
%
% INPUTS:
%   simpName - Cell array with simplified structure names
%
% OUTPUTS:
%   colorList - RBG matrix with colors of plots for each neuron. Columns are RBG. Rows are individual neurons
%
% Written by Scott Kilianski
% Updated on 2025-09-26
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
for ni = 1:numel(simpName)
        % --- Removing that annoying ' from the end of structure names --- %
    str = simpName{ni};
    if strcmp(str(end),"'")
        str = str(1:end-1);
    end

switch str
    case 'Somatosensory'
        colorList(ni,:) = [1.00, 0.50, 0.05];   % Orange
    case 'Visual'
        colorList(ni,:) = [0.36, 0.68, 0.89];   % Light Blue
    case 'Frontal'
        colorList(ni,:) = [0.54, 0.17, 0.89];   % Violet
    case 'Hipp'
        colorList(ni,:) = [0.13, 0.70, 0.67];   % Teal
    case 'Caudoputamen'
        colorList(ni,:) = [1.00, 0.84, 0.00];   % Golden Yellow
    otherwise
        colorList(ni,:) = [0, 0, 0];            % Default black if no match
end


end % function end