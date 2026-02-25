%%
topdir = '/media/scott2X/PSR_Data/PSR_20/PSR_20_Rec2_231019_152639/';
load(fullfile(topdir,'seizures_EEG.mat'),'seizures');

sz = seizures;

% --- Get only good seizures (type 1 and 2s) --- %
goodLog = strcmp({sz.type},'1') | strcmp({sz.type},'2');
sz(~goodLog) = [];

[spikeArray, neuronChans, clustIDs] = psr_makeSpikeArray(fullfile(topdir,'kilosort4/'));
%%
[szCounts, MUcounts] = psr_spikePhase(spikeArray,sz);

%%
cinf = readtable(fullfile(topdir,'CellInfo.csv'),...
    'Delimiter',',');           % load in the Cell infomation table
colorList = psr_assignColors(cinf.SimpleName); % assign colors to neurons

[mv, fa] = psr_spikePhasePref(szCounts,colorList);     % make the polar plots

%%
[nismAN, prefPhase, fa, pph] = psr_spikePolarPlots(szCounts);

%%
nn = 10; % neuron number
hold on
polarplot(deg2rad([mv.a(nn) mv.a(nn)]), ...
    [0 mv.L(nn)],...
    'k-','LineWidth',4);
%%

[mv.a(1) mv.L(1)]
[mv.a(3) mv.L(3)]
[mv.a(6) mv.L(6)]