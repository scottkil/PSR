function [gfit, fls] = psr_fitGaussian(spka)
%% psr_fitGaussian Fits Gaussian function to spikes amplitudes
%
% INPUTS:
%   spka - vector of spike amplitudes
%
% OUTPUTS:
%   gfit - structure with following fields:
%           - mu: mean for fitted Gaussian
%           - sig: standard deviation for fitted Gaussian
%   fls - a structure with following fields:
%           - x: x-values for the fitted least squares probability distribution function (PDF)
%           - y: y-values for PDF
%
% Written by Scott Kilianski
% Updated on 2025-09-08
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
% plotFlag = 1; 

% --- Step 1: Using KDE to estimate data distribution --- %
[fVals, xVals] = ksdensity(spka); % kernel density estimate
[~, maxI] = max(fVals); % get peak of distribution
split_point = xVals(maxI);  % or use mode(data)

% ---- Step 2: Extract right half and mirror it around the split ----%
right_half = spka(spka >= split_point);
mirrored = 2*split_point - right_half;
symmetric_data = [right_half; mirrored];

% ---- Step 3: Fit a Gaussian to the symmetrized distribution ---- %
% This is done to get mean and SD of symmetric_data %
pd_sym = fitdist(symmetric_data, 'Normal');
mu_sym = pd_sym.mu;
sigma_sym = pd_sym.sigma;

% --- Step 4: Take KDE of symmetric data --- %
[f_empirical, x_empirical] = ksdensity(symmetric_data);

% --- Step 5: Fit Gaussian to KDE using lsqcurvefit --- %
gauss_model = @(p, x) normpdf(x, p(1), p(2));
params0 = [mu_sym, sigma_sym];
params_fit = lsqcurvefit(gauss_model, params0, x_empirical, f_empirical);
mu_ls = params_fit(1);
sigma_ls = params_fit(2);
fitted_ls = normpdf(x_empirical, mu_ls, sigma_ls);

% --- Plot --- %
% if plotFlag
%     fitted_ls = normpdf(x_empirical, mu_ls, sigma_ls);
%     cf = figure("Position", [850, 120, 1037, 902],...
%         'Visible','off');
%     subplot(1,3,2:3);
%     histogram(spka,'Normalization','pdf')
%     hold on;
%     plot(x_empirical, fitted_ls, 'r--', 'LineWidth', 2, 'DisplayName', 'Fitted Gaussian');
% 
% end

gfit.mu = mu_ls;
gfit.sig = sigma_ls;
fls.x = x_empirical; 
fls.y = fitted_ls;

end % function end