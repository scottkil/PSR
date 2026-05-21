%%
topdir = '/media/scott4X/PSR_Data_Ext/PSR_40_Day1/PSR_40_Day1_Rec2_250214_225128/';
spikeArray = psr_makeSpikeArray(fullfile(topdir,'kilosort4/'));
seizFile = fullfile(topdir,'seizures_EEG.mat');
load(seizFile,'seizures')
keepLog = strcmp({seizures.type},'1') | strcmp({seizures.type},'2');
seizures(~keepLog) = [];


NN = 4; % neuron ID to look at
st = spikeArray{NN}; % spike times
X = [];
Y = []; 
k = 0; % y-position index
for szi = 1:numel(seizures)
    sz = seizures(szi); % retrieve current seizure info
     for cyci = 1:numel(sz.trTimeInds)-1
         k = k+1;
        cycSE = [sz.time(sz.trTimeInds(cyci)),...
            sz.time(sz.trTimeInds(cyci+1))];        % get the current SW cycle start and end times
        cst = st(st >= cycSE(1) & st < cycSE(2)); % get relevant spike times
        stpos = (cst-cycSE(1)) / diff(cycSE); % find the position between cycles
        stz = stpos*2*pi;
        X = [X;stz];
        ypos = ones(size(stz))*k; % Y-position for scatter plot
        Y = [Y; ypos]; 
     end
end

%% --- Circularly shift phases for rasters are centered --- %
Xmod = X;
Xmod(Xmod>pi) = Xmod(Xmod>pi)- (2*pi);
Xdeg = rad2deg(Xmod);
% --- Raster  Plot --- %
figure;
scatter(Xdeg,Y,'k','|','LineWidth',3)
xlim([-180 180]);
set(gca,'YDir','reverse')
hold on
szk = 0.5;
for szi = 1:numel(seizures)
    szk=szk+ numel(seizures(szi).trTimeInds);
    yline(szk)
end
set(gca,'FontSize',24)