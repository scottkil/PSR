function assignVec = psr_structAssign(simpName)
%% psr_structAssign Assigns all structures a number of sorting purposes
%
% INPUTS:
%   simpName - cell array with names of brain region for each neuron
%
% OUTPUTS:
%   assignVec - vector with sorted number assignments with following order:
%       Frontal - 1
%       Somatosensory - 2
%       Visual - 3
%       Caudoputamen - 4
%       Hipp - 5
%
% Written by Scott Kilianski
% Updated on 2026-02-24
% ------------------------------------------------------------ %
%% === Function Body Below === %
assignVec = ones(size(simpName)) * 6; % 6: no structure assignment

assignVec(contains(simpName,'Frontal') ) = 1; 

assignVec(contains(simpName,'Somatosensory')) = 2;

assignVec(contains(simpName,'Visual')) = 3;

assignVec(contains(simpName,'Caudoputamen')) = 4;

assignVec(contains(simpName,'Hipp')) = 5;

end % function end

