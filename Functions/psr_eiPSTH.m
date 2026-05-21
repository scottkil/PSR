function [psth, timevec] = psr_eiPSTH(topdir, twin, dt,buff)
%% psr_eiPSTH Generates peri-SWD time histogram for summed excitatory (unclassified) and inhibitory neuronal activity
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for summing activity.Default is 0.025
%   dt - time step of output vector (in seconds). Default is 0.001
%   buff - buffer time (in seconds) to look before and after SWDs. Default is 5
%
% OUTPUTS:
%   psth - a structure with the following fields. Each element is different brain region
%           - aa: start PSTHs. Top row is excitatory (unclassified) neurons and bottom is inhibitory
%           - bb: end PSTHs. same organization as aa
%           - name: brain region name
%
%   timevec - time vector corresponding to psth width
%
% Written by Scott Kilianski
% Updated on 2026-04-07
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%
% --- Handle Inputs --- %
if nargin < 2
    twin = 0.025;
    dt = 0.001;
    buff = 5;
elseif nargin < 3
    dt = 0.001;
    buff = 5;
elseif nargin < 4
    buff = 5;
end

% --- Set and calculate important variables --- %
FS = 30000;                         % sampling frequency
buffSamp = buff/dt;                 % buffer (in samples)
timevec = (-buffSamp:buffSamp)*dt;  % corresponding time vector for output structure

% --- Get recording start and end --- %
tsFile = fullfile(topdir,'timestamps.bin');
tsFID = fopen(tsFile);
TS = fread(tsFID,Inf,'int32');
load(fullfile(topdir,'seizures_EEG.mat'),'seizures');
recSE = double([TS(1),TS(end)])./FS; % recording start and end (in seconds)
fclose(tsFID);

sstend = psr_findsstend(seizures,recSE); % get start and end times of all seizures
eiVec = psr_EIvec(topdir,twin,dt);       % excitatory and inhibitory summed spikes

% --- Loop over each brain structure to --- %
for brii = 1:numel(eiVec.sn) % brain region (structure) loop
    AAe = []; AAi = []; BBe = []; BBi = [];

    zE = zscore(eiVec.vals{brii}(1,:));
    zI = zscore(eiVec.vals{brii}(2,:));

    k = 0; % seizure indexing variable
    for szii = 1:size(sstend,1)         % loop for each seizures
        aa = sstend(szii,1); % seizure start time
        bb = sstend(szii,2); % seizure end time

        % --- Get closest times in eiVec.time to STARTS and ENDS of seizures --- %
        [~,minIDX] = min(abs(eiVec.time-aa));         % find closest time to seizure start in eiVec.time
        idxr_a = (minIDX-buffSamp):(minIDX+buffSamp); % index range for START

        [~,minIDX] = min(abs(eiVec.time-bb));         % find closest time to seizure end in eiVec.time
        idxr_b = (minIDX-buffSamp):(minIDX+buffSamp); % index range for end of seizure END

        % --- Skip at edge conflicts --- %
        if any(idxr_a <= 0) % if too close to recording start, skip
            continue
        elseif any(idxr_b > length(eiVec.time)) % or too close to recording end, skip
            continue
        end
        k = k+1;
        AAe(k,:) = zE(idxr_a);
        AAi(k,:) = zI(idxr_a);
        
        BBe(k,:) = zE(idxr_b);
        BBi(k,:) = zI(idxr_b);

    end

    % --- Store in output structure --- %
    psth(brii).aa(1,:) = mean(AAe,1,'omitmissing');
    psth(brii).aa(2,:) = mean(AAi,1,'omitmissing');
    psth(brii).bb(1,:) = mean(BBe,1,'omitmissing');
    psth(brii).bb(2,:) = mean(BBi,1,'omitmissing');
    psth(brii).name = eiVec.sn{brii};
end