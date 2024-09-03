%%

xdir = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850';
% xdir = 'Y:\PSR_Data\PSR_16\PSR_16_Rec2_231011_173634'; % directory 
% xdir = 'Y:\PSR_Data\PSR_20\PSR_20_Rec2_231019_152639';
fname = uigetfile(xdir); % load 'seizures'
load(fullfile(xdir,fname),'seizures');
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
seizures(~keepLog) = [];
spikeArray = psr_makeSpikeArray(xdir);
[szCounts, MUcounts] = psr_spikePhase(spikeArray,seizures);
%%
[nismAN, prefPhase] = psr_spikePolarPlots(szCounts);
% negInd = prefPhase<=0;
% prefPhase(negInd) = prefPhase(negInd)+360;
% [hc,bie] = histcounts(prefPhase,'BinEdges',linspace(0, 360,101),'Normalization','probability');
% bc = bie(2:end) - abs(diff(bie(1:2))/2);
% figure;
% bar(bc,hc);
