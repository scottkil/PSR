%%
% --- Uses 'bigCounts' which is generated from waveform_featureScatters_perRecording.m --- %
cf1 = figure; 
bar(bigCounts.ttp_time,bigCounts.ttp_vals,'stacked');


xlabel('Trough-to-peak time (ms)');
ylabel('# Neurons');
title('Trough-to-peak:  All Neurons, All Mice');
set(gcf().Children,'FontSize',16)
   exportgraphics(cf1, '/home/scott/Documents/TTP.pdf');
%%
cf2 = figure; 
bar(bigCounts.hlfdur_time,bigCounts.hlfdur_vals,'stacked');


xlabel('Half-amplitude Duration (ms)');
ylabel('# Neurons');
title('Half-amplitude Duration:  All Neurons, All Mice');
set(gcf().Children,'FontSize',16)
   exportgraphics(cf2,'/home/scott/Documents/halfDurs.pdf');