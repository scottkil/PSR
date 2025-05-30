function bombFun(topdir)
%% Getting started with bombcell
%% Set paths
% Toy dataset location you can play around with. This only has a few units to 
% make it lightweight and easy to load.

% toy_dataset_location = [fileparts(matlab.desktop.editor.getActiveFilename), filesep, 'toy_data', filesep];
%% 
% These paths below are the paths you will need to input to load data and save 
% the computed quality metrics / ephys properties. Here we are leaving ephysRawFile 
% as "NaN" to not load raw data (it is too cumbersome to store these large files 
% on github). All metrics relating to raw data (amplitude, signal to noise ratio) 
% will not be computed. 

ephysKilosortPath = topdir;
ephysRawFile = fullfile(ephysKilosortPath,'combined.bin'); % path to your raw .bin or .dat data
% ephysMetaDir = dir([toy_dataset_location '*ap*.*meta']); % path to your .meta or .oebin meta file
ephysMetaDir = [];
savePath = [ephysKilosortPath filesep 'bombcell']; % where you want to save the quality metrics 
%
% Two parameters to pay attention to: the kilosort version (change to kilosortVersion 
% = 4 if you are using kilosort4) and the gain_to_uV scaling factor (this is the 
% scaling factor to apply to your data to get it in microVolts).

kilosortVersion = 2; % if using kilosort4, you need to have this value kilosertVersion=4. Otherwise it does not matter. 
gain_to_uV = 0.195; % use this if you are not using spikeGLX or openEphys to record your data. this value, 
% when mulitplied by your raw data should convert it to  microvolts. 
%% Load data
% This function loads are your ephys data. Use this function rather than any 
% custom one as it handles zero-indexed values in a particular way. 

[spikeTimes_samples, spikeClusters, templateWaveforms, templateAmplitudes, pcFeatures, ...
    pcFeatureIdx, channelPositions] = bc.load.loadEphysData(ephysKilosortPath, savePath);
%% Run quality metrics
% Set your paramaters. 
% These define both how you will run quality metrics and how thresholds will 
% be applied to quality metrics to classify units into good/MUA/noise/non-axonal. 
% This function loads default, permissive values. It's highly recommended for 
% you to iteratively tweak these values to find values that suit your particular 
% use case! 

param = bc.qm.qualityParamValues(ephysMetaDir, ephysRawFile, ephysKilosortPath, gain_to_uV, kilosortVersion);
% Pay particular attention to |param.nChannels|
% |param.nChannels| must correspond to the total number of channels in your 
% raw data, including any sync channels. For Neuropixels probes, this value should 
% typically be either 384 or 385 channels. |param.nSyncChannels| must correspond 
% to the number of sync channels you recorded. This value is typically 1 or 0.

param.nChannels = 256;
param.nSyncChannels = 0;

% if using SpikeGLX, you can use this function: 
if ~isempty(ephysMetaDir)
    if endsWith(ephysMetaDir.name, '.ap.meta') %spikeGLX file-naming convention
        meta = bc.dependencies.SGLX_readMeta.ReadMeta(ephysMetaDir.name, ephysMetaDir.folder);
        [AP, ~, SY] = bc.dependencies.SGLX_readMeta.ChannelCountsIM(meta);
        param.nChannels = AP + SY;
        param.nSyncChannels = SY;
    end
end
% Run all your quality metrics! 
% This function runs all quality metrics, saves the metrics in your savePath 
% folder and outputs some global summary plots that can give you a good idea of 
% how things went. 

%param.computeDistanceMetrics=1;
%param.computeDrift=1;
param.computeTimeChunks=0;
%param.removeDuplicateSpikes=1;
param.tauR_valuesMin = 0.5/1000;
param.tauR_valuesMax = 0.01;
param.tauR_valuesStep = 0.5/1000;
param.computeDrift = 0;
param.computeDistanceMetrics = 0;
param.removeDuplicateSpikes = 0;
param.hillOrLlobetMethod = 1;
param.computeTimeChunks = 0;
param.extractRaw = 0;
param.reextractRaw = 0;
[qMetric, unitType] = bc.qm.runAllQualityMetrics(param, spikeTimes_samples, spikeClusters, ...
        templateWaveforms, templateAmplitudes, pcFeatures, pcFeatureIdx, channelPositions, savePath);
%% Inspect
% After running quality metrics, espacially the first few times, it's a good 
% idea to inspect your data and the quality metrics using the built-in GUI. Use 
% your keyboard to navigate the GUI: 

% * left/right arrow : toggle between units 
% * u  : brings up a input dialog to enter the unit you want to go to
% * g  : go to next good unit 
% * m : go to next multi-unit 
% * n  : go to next noise unit
% * a  : go to next non-somatic unit ("a" is for axonal)
% * up/down arrow : toggle between time chunks in the raw data

bc.load.loadMetricsForGUI;

unitQualityGuiHandle = bc.viz.unitQualityGUI_synced(memMapData, ephysData, qMetric, forGUI, rawWaveforms, ...
    param, probeLocation, unitType, loadRawTraces);
%% Examples
% Get the quality metrics for one unit
% This is an example to get the quality metric for the unit with the original 
% kilosort and phy label of xx (0-indexed), which corresponds to the unit with 
% qMetric.clusterID == xx + 1, and to qMetric.phy_clusterID == xx . This is *NOT 
% NECESSARILY* the (xx + 1)th row of the structure qMetric - some of the  clusters 
% that kilosort outputs are empty, because they were dropped in the last stages 
% of the algorithm. These empty clusters are not included in the qMetric structure.
% 
% There are two ways to do this: 
% 
% 1:


% original_id_we_want_to_load = 0;
% id_we_want_to_load_1_indexed = original_id_we_want_to_load + 1; 
%number_of_spikes_for_this_cluster = qMetric.nSpikes(qMetric.clusterID == id_we_want_to_load_1_indexed);
%
% or 2:

original_id_we_want_to_load = 0;
number_of_spikes_for_this_cluster = qMetric.nSpikes(qMetric.phy_clusterID == original_id_we_want_to_load);
% Get the unit labels 
% The output of `unitType = getQualityUnitType(param, qMetric);` gives  the 
% unitType in a number format. 1 indicates good units, 2 indicates mua units, 
% 3  indicates non-somatic units and 0 indciates noise units (see below) 

goodUnits = unitType == 1;
muaUnits = unitType == 2;
noiseUnits = unitType == 0;
nonSomaticUnits = unitType == 3; 

% example: get all good units number of spikes
all_good_units_number_of_spikes = qMetric.nSpikes(goodUnits);

% (for use with another language: output a .tsv file of labels. You can then simply load this) 
label_table = table(unitType);
writetable(label_table,[savePath filesep 'templates._bc_unit_labels.tsv'],'FileType', 'text','Delimiter','\t');  
      
% Change a classification paramater and re-compute the unit classifications and output plots

param.maxPercSpikesMissing = 30;
unitType = bc.qm.getQualityUnitType(param, qMetric, savePath);
bc.qm.plotGlobalQualityMetric(param, ephysKilosortPath, savePath);
%% 
%% Run ephys properties
% Optionally get ephys properties for your cell. Bombcell will also attempt 
% to classify your data if it is (a) from the cortex or striatum and (b) you specify 
% this in the "region" variable.

% rerunEP = 0;
% region = 'cortex'; % options include 'Striatum' and 'Cortex'
% [ephysProperties, unitClassif] = bc.ep.runAllEphysProperties(ephysKilosortPath, savePath, rerunEP, region);

%%
close all % close all figures that Bombcell function creates

end % function end