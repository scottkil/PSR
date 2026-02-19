%%
clear all; close all; clc
topDir = '/home/scott/DLC_Projects/PSR_38_Day1-Scott-2026-02-06/videos/';
dd = dir(topDir);
fnames = {dd.name};
mat_file = fullfile(topDir,dd(contains(fnames,'.mat')).name);
csv_file = fullfile(topDir,dd(contains(fnames,'.csv')).name);

C = readcell(csv_file,'Delimiter',',');
pupFile = '/media/scott4X/PSR_Data_Ext/PSR_38_Day1/PSR_38_Day1_Rec2_250211_203755/pupilData.mat';
load(pupFile,'pupil')

pup(:,:,1) = cell2mat(C(4:end,2:4));
pup(:,:,2) = cell2mat(C(4:end,5:7));
pup(:,:,3) = cell2mat(C(4:end,8:10));
pup(:,:,4) = cell2mat(C(4:end,11:13));
pup(:,:,5) = cell2mat(C(4:end,14:16));
pup(:,:,6) = cell2mat(C(4:end,17:19));
pup(:,:,7) = cell2mat(C(4:end,20:22));
pup(:,:,8) = cell2mat(C(4:end,23:25));
pup(:,:,9) = cell2mat(C(4:end,26:28));
load(mat_file, 'eyeIM');


%%
figure;
eyeAX = axes;
k = 1; % frame number
eIM = imagesc(eyeIM(:,:,k));
eyeAX.CLim = [0 255];
eyeAX.CLimMode = 'manual';
colormap(gray)
hold on
xp = squeeze(pup(k,1,:));
yp = squeeze(pup(k,2,:));
% scatt = scatter(xp,yp,'red','*');
bfl = plot(0,0,'m', 'LineWidth', 3);
tl = title('','FontSize',12);
%
k = 58765; % frame number
fprintf('%d\n',k);
eIM.CData = eyeIM(:,:,k);
xp = squeeze(pup(k,1,1:end-1));
yp = squeeze(pup(k,2,1:end-1));

confP = squeeze(pup(k,3,1:end-1));
goodLog = confP > 0.1 ; % only keeping high-confidence points
xp = xp(goodLog);
yp = yp(goodLog);

% set(scatt,'XData',xp,...
%     'YData',yp);


x = xp;
y = yp;
A = [2*x 2*y ones(size(x))];
b = x.^2 + y.^2;

p = A\b;

xc = p(1);
yc = p(2);
r  = sqrt(p(3) + xc^2 + yc^2);

%
theta = linspace(0,2*pi,400);
% plot(x,y,'ko'); hold on
set(bfl,'XData',xc + r*cos(theta),...
    'YData',yc + r*sin(theta));

% tl.String = sprintf('Mean Likelihood %.3f',mean(pup(k,3,:)));
tl.String = sprintf('%d',pupil.ft(k));

%%
title('');
axis off