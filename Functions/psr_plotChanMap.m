function psr_plotChanMap
%plotChanMap Plots the channel map of selected probe configuration
%Written by SK 5/6/2020

uiload; %bring up Windows Explorer UI to select channel map configuration
figure;
scatter(xcoords, ycoords, 1000, 's');
hold on
textscatter(xcoords, ycoords, cellstr(num2str(chanMap0ind)),'TextDensityPercentage',100);
hold off
end

