%%
% --- Grab 3 SWD-centered PETHs --- %
xv = -0.05:0.001:0.05;
xv = xv*1000; % convert to milliseconds
% xt = ;
IDXs = [3, 20,37];
ord1 = sh.two.ord(:,1);
COMS_sorted = sh.two.com(ord1,:);
MAT_sorted = sh.two.mat(ord1,:,:);

figure; 
clrList = [.7, .2, .2;...
    .2,.35,.7;...
    .25,.55,.3];
for ii = 1:numel(IDXs)
    yv1 = MAT_sorted(IDXs(ii),:,1);
    yv2 = MAT_sorted(IDXs(ii),:,2);
    sx1 = COMS_sorted(IDXs(ii),1)*1000;
    sx2 = COMS_sorted(IDXs(ii),2)*1000;

    plot(xv,yv1,'Color',clrList(ii,:),'LineWidth',2.5);
    hold on
    xline(sx1,'Color',clrList(ii,:),'LineWidth',2);
    plot(xv,yv2,'--','Color',clrList(ii,:),'LineWidth',2.5)
    xline(sx2,'--','Color',clrList(ii,:),'LineWidth',2)
end
xlim([-25 25])
set(gca,'FontSize',24)