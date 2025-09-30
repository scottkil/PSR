function R = psr_computeRfromQ(Q)
%% psr_computeRfromQ Computes R matrices from cell arry of Q matrices 
%
% INPUTS:
%   Q - a cell array of binned spike rate matrices, output from psr_makeSeizQ
%
% OUTPUTS:
%   R - a cell array of correlation matrices (R)
%
% Written by Scott Kilianski
% Updated on 2025-09-29
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
fprintf('Computing correlation matrices (Rs)...\n')
for ei = 1:numel(Q)
    cq = Q{ei};            % get current Q matrix
    R{ei,1} = corrcoef(cq');  % compute pairwise correlations
end

end % function end