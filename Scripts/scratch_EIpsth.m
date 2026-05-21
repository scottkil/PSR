function psth = psr_eiPSTH(topdir, twin, dt)
%% psr_eiPSTH Template for functions 
%
% INPUTS:
%   topdir - path to top-level data directory
%   twin - time window for computing proportion of population active.Default is 0.025
%   dt - time step of output vector (in seconds). Default is 0.001
%
% OUTPUTS:
%   output1 - Description of output variable
%
% Written by Author
% Updated on YYYY-MM-DD
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%

clear all; clc
topdir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day1/PSR_40_Day1_Rec2_250214_225128/';
FS = 30000; % sampling frequency
twin = .500; % time window to sum spikes
dt = .05; % time step for summing window 
buff = 5; % time buffer ( in seconds)
buffSamp = buff/dt;  % buffer (in samples)
timevec = (-buffSamp:buffSamp)*dt;
eiVec = psr_EIvec(topdir,twin,dt); % excitatory and inhibitory summed spikes

%% --- Handle timestamps --- %
tsFile = fullfile(topdir,'timestamps.bin');
tsFID = fopen(tsFile);
TS = fread(tsFID,Inf,'int32');
load(fullfile(topdir,'seizures_EEG.mat'),'seizures');
recSE = double([TS(1),TS(end)])./FS; % recording start and end (in seconds)
fclose(tsFID);
sstend = psr_findsstend(seizures,recSE); % get start and end times of all seizures
%%

for brii = 1:numel(eiVec.sn) % brain region (structure) loop
    AAe = []; AAi = []; BBe = []; BBi = [];

    zE = zscore(eiVec.vals{brii}(1,:));
    zI = zscore(eiVec.vals{brii}(2,:));

    for szii = 1:size(sstend,1)         % loop for each seizures
        aa = sstend(szii,1); % seizure start time
        bb = sstend(szii,2); % seizure end time

        % --- Get closest times in eiVec.time to STARTS and ENDS of seizures --- %
        [~,minIDX] = min(abs(eiVec.time-aa)); % find closest time to seizure start in eiVec.time
        idxr_a = (minIDX-buffSamp):(minIDX+buffSamp); % index range for START

        [~,minIDX] = min(abs(eiVec.time-bb)); % find closest time to seizure end in eiVec.time
        idxr_b = (minIDX-buffSamp):(minIDX+buffSamp); % index range for end of seizure END

        % --- Skip at edge conflicts --- %
        if any(idxr_a <= 0) % if too close to recording start, skip
            continue
        elseif any(idxr_b > length(eiVec.time)) % or too close to recording end, skip
            continue
        end


        AAe(szii,:) = zE(idxr_a);
        AAi(szii,:) = zI(idxr_a);
        
        BBe(szii,:) = zE(idxr_b);
        BBi(szii,:) = zI(idxr_b);

    end

    psth(brii).aa(1,:) = mean(AAe,1,'omitmissing');
    psth(brii).aa(2,:) = mean(AAi,1,'omitmissing');
    psth(brii).bb(1,:) = mean(BBe,1,'omitmissing');
    psth(brii).bb(2,:) = mean(BBi,1,'omitmissing');
    psth(brii).name = eiVec.sn{brii};
end


%%
figure;
plot(timevec, psth(2).aa(2,:))