function psr_spikePhaseAndPlot(xdir)
%% psr_spikePhaseAndPlot Calculates spike phases relative to SWD and plots and saves those plots 
%
% INPUTS:
%   xdir - Home directory for a single recording
%
% OUTPUTS:
%   Saves output PDF in the home directory
%
% Written by Scott Kilianski
% Updated on 2025-09-26
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
fname = 'seizures_EEG.mat';             % full file name for manually labeled seizures file
load(fullfile(xdir,fname),'seizures');  % load manually labeled 'seizures'
ksdir = fullfile(xdir,'kilosort4');     % filepath to kilosort output directory
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2'); % keep the good seizures
seizures(~keepLog) = [];        % remove the bad seizures
cinf = readtable(fullfile(xdir,'CellInfo.csv'),...
    'Delimiter',',');           % load in the Cell infomation table
simpName = cinf.SimpleName;     % simple name list
cLayer = cinf.CorticalLayer;    % cortical layer list
colorList = psr_assignColors(simpName); % assign colors to neurons

% -- Loading spikes, finding their SWD phase, finding neurons' phase preference --- %
spikeArray = psr_makeSpikeArray(ksdir); % make the spike cell array
[szCounts, MUcounts] = psr_spikePhase(spikeArray,seizures);     % calculate spike phase (relative to SWD)
[mv, fa] = psr_spikePhasePref(szCounts,colorList);     % make the polar plots

% --- Output PDF with figures appended --- %
pfFile = sprintf('%s%s.pdf',xdir,'PhaseFigures');
if exist(pfFile,'file')
    fprintf('Deleting and recreating %s\n',pfFile)
    delete(pfFile); % Remove existing PDF file to avoid appending to an old file
end

for ni = 1:numel(fa)
    fprintf('Appending neuron %d...\n',ni)
    % --- Removing that annoying ' from the end of structure names --- %
    str = simpName{ni};
    if strcmp(str(end),"'")
        str = str(1:end-1);
    end

    if cLayer(ni)
        SLstring = sprintf('Neuron %d - %s - Layer %d',...
            cinf.UniqueNeuron_(ni),str,cLayer(ni)); % structure and layer
    else
        SLstring = sprintf('Neuron %d - %s',...
            cinf.UniqueNeuron_(ni), str); % structure and layer
    end
    set(fa(ni).Children.Title,...
        'String',SLstring); % set the title to the appropriate name
    drawnow;
    exportgraphics(fa(ni), pfFile,...
        'ContentType','image', 'Resolution',300,...
        'Append', true);
end

close all; % close all figures

mvName = fullfile(xdir,'MeanVectors.mat'); 
save(mvName,'mv','-v7.3');

end % function end