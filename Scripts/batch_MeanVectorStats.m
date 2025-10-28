%%
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');       % read in data table
recfin = readtable('/home/scott/Documents/PSR/Data/RecordingInfo.csv',...
    'Delimiter',',');       % read in recording info data
simpName = dtbl.SimpleName; % get the structure names
ubrs = unique(simpName);

MVL = dtbl.MeanVectorLength_toFCXEEG_;
MVA = dtbl.MeanVectorAngle_toFCXEEG_;
clc;

%%
mv = {};
for sii = 1:numel(ubrs)
    cLog = strcmp(simpName,ubrs{sii});
    mv{sii,2} = MVL(cLog);
    mv{sii,3} = MVA(cLog);
    mv{sii,1} = ubrs{sii};
end

%% First attempt at plotting population histograms and mean vectors %%
close all;
npb = 50; % number of phase bins
colorList = psr_assignColors(ubrs);
phaseVec = linspace(-pi,pi,npb)';   % make corresponding phase vector for 1 cycle (-π to π)
ave = linspace(-pi,pi,npb+1); % angle vector (bin edges) for polar histogram

for sii = 1:numel(ubrs)
    vLens = mv{sii,2}; % vector lengths
    vAngs = mv{sii,3}; % vector angles

    normCounts = histcounts(vAngs,'NumBins',npb,'Normalization','Probability');
    % phCounts = circshift(binCounts,npb/2);
    % normCounts = phCounts./sum(phCounts);
    normCounts = circshift(normCounts,npb/2);


    complex_vector = vLens .* exp(1i * deg2rad(vAngs)); % product of vector lengths and angles
    mean_vector = sum(complex_vector,'omitnan'); % weighted average of all neurons' vectors (weighted based on vector lengths [i.e. neurons with strong phase-locking (high MVL) count more])
    mvl(sii) = abs(mean_vector) / sum(vLens,'omitnan');                       % Normalized strength of phase locking (0 - none, 1 - max)
    mva(sii) = angle(mean_vector);
    mvadeg(sii) = rad2deg(mva(sii));                   % convert mean vector angle to degrees

    cf = figure;
    cph = polarhistogram('BinEdges',ave,...
        'BinCounts',normCounts,...
        'FaceColor',colorList(sii,:),'EdgeColor','none',...
        'FaceAlpha',0.75);
    set(gca,'GridAlpha',0.6,'GridColor',[0 0 0])
    % rlim([0 0.25])
    title(ubrs{sii})
    set(cf.Children,'FontSize',14)
end


plf = figure;
plax = polaraxes;
hold on
for sii = [1,6,4,5,3]
    plp(sii) = polarplot([mva(sii), mva(sii)], [0, mvl(sii)],...
        'Color',colorList(sii,:),'LineWidth',5);
end
hold off
set(plax,'GridAlpha',0.6,'GridColor',[0 0 0])
set(plf.Children,'FontSize',14)
rlim([0 1])

%% One example for a structure - caudoputamen %%
plf = figure;

plotList = [6,5,3,4,1];
for sii = 1:numel(plotList)%[1,3,4,5,6]%1:numel(ubrs)
    plax(sii) = subplot(2,3,sii,polaraxes);
    xidx = plotList(sii);
    vA = mv{xidx,3};
    vL = mv{xidx,2};
    ps = polarscatter(deg2rad(vA),vL,'filled');
    ps.MarkerFaceColor = colorList(xidx,:);
    ps.MarkerFaceAlpha = '0.5';
    ps.SizeData = 72;
    rlim([0 1])
end


%
plax(6) = subplot(2,3,6,polaraxes);
% plax = polaraxes(sax(6));
hold on
for sii = [1,6,4,5,3]
    % plp(sii) = polarplot([mva(sii), mva(sii)], [0, mvl(sii)],...
    %     'Color',colorList(sii,:),'LineWidth',5);
        plp(sii) = polarscatter(mva(sii), mvl(sii),'filled');
        plp(sii).MarkerFaceColor = colorList(sii,:);
        plp(sii).MarkerFaceAlpha = '0.75';
        plp(sii).SizeData = numel(mv{sii,2}) * 0.8;
end
hold off
set(plax,'GridAlpha',0.6,'GridColor',[0 0 0])
% set(plf.Children,'FontSize',14)
rlim([0 1])
set(plf.Children,'FontSize',14)
