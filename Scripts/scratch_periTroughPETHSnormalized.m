%%
twin = 0.2;
topdir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day2/PSR_40_Day2_Rec1_250215_173210/';
[spkPETH, binCen] = psr_PETH_units_swd(topdir,twin); % compute the PETHs around SWD spikes
msp = mean(spkPETH,3);
%%
smoothPETH = smoothdata(msp,2,'gaussian',25);

divMat = repmat(max(smoothPETH,[],2),1,size(spkPETH,2));
normPETH = smoothPETH ./ divMat; % Normalize the PETHs by the maximum mean spike count


% Plot the normalized PETH
[~,maxORD] = max(normPETH,[],2);
[~,plotORD] = sort(maxORD,'ascend');

figure;
% imagesc(binCen, 1:size(normPETH, 1), normPETH);
imagesc(binCen, 1:size(normPETH, 1), normPETH(plotORD,:));
colorbar;
xlabel('Time (s)');
ylabel('Units');
title('Normalized PETH');
colormap(jet)