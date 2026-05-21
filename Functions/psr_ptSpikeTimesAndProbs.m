function ptspk = psr_ptSpikeTimesAndProbs(topdir,winSize,winStep)
%% psr_ptSpikeTimesAndProbs Finds peri-trough spike times and probabilities
%
% INPUTS:
%   topdir - top-level directory
%   winSize - window size around the trough to look for spikes (in seconds)
%   winStep - step size from window to window (in seconds, must be smaller than winSize)
%
% OUTPUTS:
%   ptspk - peri-trough spiking structure with following fields:
%           - rSpikeTimes: relative spike times (relative to nearby troughs)
%           - spkProb: peri-trough spike probability (1 if all fires at given time point)
%           - CE: bin centers corrsponding to spkProb
%           - spkF: first spike times
%           - spkL: last spike times
%
% Written by Scott Kilianski
% Updated on 2026-04-16
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
if nargin < 2
    winSize = 0.05; % Set default window size if not provided
    winStep = 0.001; % Set default step size if not provided
elseif nargin <3
    winStep = 0.001;
end
halfWin = winSize/2;
seizFile = fullfile(topdir,'seizures_EEG.mat');
KSdir = fullfile(topdir,'kilosort4/');
spikeArray = psr_makeSpikeArray(KSdir);
TT = psr_getTroughTimes(seizFile);

winE = -halfWin:winStep:halfWin;
ptspk.CE = winE(1:end-1)+(winStep/2); % histogram bin centers
for nii = 1:numel(spikeArray)
    spkHold = [];  % hold all relative spike times
    spkLog = [];   % spike probability log
    for ttii = 1:numel(TT)
        % --- Retrieve all spikes within window --- %
        currspks = spikeArray{nii}-TT(ttii); % spike times relative to current trough
        % spktimes = currspks - TT(ttii); 
        winspks = currspks(abs(currspks)<=halfWin); % get relative spike times with peri-trough window
        % winspks = currspks(currspks >= TTsse(ttii,1) & currspks <= TTsse(ttii,2)); % spks within window
        if any(winspks)
            firstSpike(nii, ttii) = min(winspks); % first spike in the window
            lastSpike(nii, ttii) = max(winspks);  % last spike in the window
        else
            firstSpike(nii, ttii) = NaN; % no spikes in the window
            lastSpike(nii, ttii) = NaN;  % no spikes in the window
        end
        spkHold = [spkHold;winspks];
        hc = histcounts(winspks,winE);
        spkLog(ttii,:) = hc > 0;
    end
    ptspk.rSpikeTimes{nii,1} = spkHold;     % Store relative spike times for each neuron
    ptspk.spkProb(nii,:) = sum(spkLog,1)/numel(TT);
end
    ptspk.spkF = firstSpike;  % first spike times for each neuron
    ptspk.spkL = lastSpike;   % last spike times for each neuron

end % function end
