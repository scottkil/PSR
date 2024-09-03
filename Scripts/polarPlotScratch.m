%%
xdir = 'Y:\PSR_Data\PSR_15\PSR_15_Rec2_231010_171850'; % directory 
load(uigetdir(xdir)); % load 'seizures'
spikeArray = psr_makeSpikeArray(xdir);
[szCounts, MUcounts] = psr_spikePhase(spikeArray,seizures);
[nismAN, prefPhase] = psr_spikePolarPlots(szCounts);
negInd = prefPhase<=0;
prefPhase(negInd) = prefPhase(negInd)+360;
[hc,bie] = histcounts(prefPhase,'BinEdges',linspace(0, 360,101),'Normalization','probability');
bc = bie(2:end) - abs(diff(bie(1:2))/2);
figure;
bar(bc,hc);
