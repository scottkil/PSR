%% Excitatory vs. Inhibitory, Firing Rates
clear all; close all; clc
dtbl = readtable('/home/scott/Documents/PSR/Data/AllCellsTable.csv',...
    'Delimiter',',');

simpName = dtbl.SimpleName;
ubrs = unique(simpName);
ubrs(strcmp(ubrs,'Excluded')) = []; % remove 'excluded' brain regions

%%
for bri = 1:numel(ubrs)
    stLog = strcmp(simpName,ubrs{bri});
    inhibLog = dtbl.Inhibitory & stLog;
    excitLog = ~dtbl.Inhibitory & stLog;
    MVA{bri,2} = dtbl.MeanVectorAngle_toFCXEEG_(excitLog);
    MVA{bri,3} = dtbl.MeanVectorAngle_toFCXEEG_(inhibLog);
    % --- Use this section to convert polar coordinates to -180 to +180
    % tmpV = [dtbl.MeanVectorAngle_toFCXEEG_(excitLog)];
    % tmpV(tmpV>180) = tmpV(tmpV>180) - 360; % anything over 180 degrees gets set to negative
    % MVA{bri,2} = tmpV;
    % tmpV = [dtbl.MeanVectorAngle_toFCXEEG_(inhibLog)];
    % tmpV(tmpV>180) = tmpV(tmpV>180) - 360; % anything over 180 degrees gets set to negative
    % MVA{bri,3} = tmpV;
    % MVA{bri,1} = ubrs{bri}; % Store the name of the brain region
    % ------------------------------------------------------------------- %
    
    MVL{bri,1} = ubrs{bri};
    MVL{bri,2} = dtbl.MeanVectorLength_toFCXEEG_(excitLog);
    MVL{bri,3} = dtbl.MeanVectorLength_toFCXEEG_(inhibLog);
end

%% Convert MVA values to mean, std, and number neurons for ANOVA later %%
U = [cellfun(@nanmean,MVA(:,2)),cellfun(@nanstd,MVA(:,2)),cellfun(@numel,MVA(:,2))]';
I = [cellfun(@nanmean,MVA(:,3)),cellfun(@nanstd,MVA(:,3)),cellfun(@numel,MVA(:,3))]';

Uall = U(:)';
Iall = I(:)';
Combined_MVA = [Uall;Iall];

%% Convert MVL values to mean, std, and number neurons for ANOVA later %%
U = [cellfun(@nanmean,MVL(:,2)),cellfun(@nanstd,MVL(:,2)),cellfun(@numel,MVL(:,2))]';
I = [cellfun(@nanmean,MVL(:,3)),cellfun(@nanstd,MVL(:,3)),cellfun(@numel,MVL(:,3))]';

Uall = U(:)';
Iall = I(:)';
Combined_MVL = [Uall;Iall];

%%
for bri = 1:numel(ubrs)
    for nti = 1:2
    L = MVL{bri,1+nti}; % excitatory first
    A = MVA{bri,1+nti}; 
    complex_vector = L .* exp(1i * deg2rad(A)); % product of vector lengths and angles    
    Z = nansum(complex_vector);
    rho(bri,nti) = abs(Z) / numel(L); % normalized to number of neurons (1 is rho/radius)
    thetaZ(bri,nti) = angle(Z);
    end
end
%%
figure;
polaraxes;
hold on
% Plot the results on the polar axes
for bri = 1:numel(ubrs)
   p(bri) =  polarplot(thetaZ(bri,:), rho(bri,:), 'o-',...
       'MarkerSize',15); % Plotting the rho values against angles
end
hold off;
rlim([0 1])