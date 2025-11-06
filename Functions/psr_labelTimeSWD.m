function SWDlabel = psr_labelTimeSWD(topdir, tv)
%% psr_labelTimeSWD Labels all time values in a vector as SWD or not based on seizures_EEG.mat data
%
% INPUTS:
%   topdir - filepath to top-level directory
%   tv - time vector (in seconds)
%
% OUTPUTS:
%   SWDlabel - logical vector same length as tv indicating whether times occur during SWD or not
%
% Written by Scott Kilianski
% Updated on 2025-11-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% --- Find start and end times of good seizures --- %
seizFile = fullfile(topdir,'seizures_EEG.mat');         % load in seizure data
load(seizFile,'seizures');   

keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % find type 1s and 2s
seizures(~keepLog) = []; % remove bad "seizures"

% -- Find start and end times of seizures -- %
for szi = 1:numel(seizures)
    tlimList(szi,1) = seizures(szi).time(seizures(szi).trTimeInds(1));   % seizure start time
    tlimList(szi,2) = seizures(szi).time(seizures(szi).trTimeInds(end)); % seizure end time
end

% --- Label all bins SWD or not --- %
SWDlabel = false(size(tv));     % initialize SWD bin labels
for szi = 1:size(tlimList,1)
    szLog = tv >= tlimList(szi,1) & tv <= tlimList(szi,2);
    SWDlabel(szLog) = true;
end
% --------------------------------- %


end % function end