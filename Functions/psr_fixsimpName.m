function simpName = psr_fixsimpName(simpName)
%% psr_fixsimpName Removes the annoying ' at the end of structure names
%
% INPUTS:
%   simpName - Cell array with simplified structure names
%
% OUTPUTS:
%   simpName - fixed
%
% Written by Scott Kilianski
% Updated on 2025-10-01
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
for ni = 1:numel(simpName)
    str = simpName{ni};
    if strcmp(str(end),"'")
        str = str(1:end-1);
    end
    simpName{ni} = str;
end

end % function end