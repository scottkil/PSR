function NN = psr_getMidvertNames(topdir)
%% psr_getMidvertNames Get names of brain structures for vertically ordered middle electrodes on both shanks
%
% INPUTS:
%   topdir - top-level directory
%
% OUTPUTS:
%   NN
%
% Written by Scott Kilianski
% Updated on 2026-04-22
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% --- Get the electrode locations --- %
load(fullfile(topdir,'electrodeLocations.mat'),'electrodeLocations');
load("MidVertChans.mat","midVert1","midVert2");
nml = readtable('NameMappingList.csv','Delimiter',',');
names = regexprep(nml.AllenAtlasName, '^[\"'']+', ''); % Remove any leading quotes (single or double)
names = regexprep(names, '[\"'']+$', ''); % Remove any trailing quotes (single or double)
for sii = 1:2 % shank loop
    if sii == 1
        n = electrodeLocations(midVert1+1,2);
    elseif sii ==2
        n = electrodeLocations(midVert2+1,2); % shank 2 electrode locations
    end
    for eii = 1:numel(n)
        LOG = strcmp(names,n{eii});
        if sum(LOG)==0
            CL = 0;
            SN = '';
        else
            CL = nml.Layer(LOG);
            SN = nml.SimplifiedName{LOG};
        end
        NN{eii,sii} = sprintf('%s-%d',SN,CL); % New Names
    end
end

end % function end