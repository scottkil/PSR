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
% Updated on 2025-09-09
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%

% ---- Step 1: Fit a Gaussian to the emperical spike amplitude distribution ---- %
% This is done to get mean and SD data %
pd_sym = fitdist(spka, 'Normal');
mu_sym = pd_sym.mu;
sigma_sym = pd_sym.sigma;

% --- Step 2: Take KDE of empirical distribution --- %
[f_empirical, x_empirical] = ksdensity(spka);

% --- Step 3: Fit Gaussian to KDE using lsqcurvefit --- %
gauss_model = @(p, x) normpdf(x, p(1), p(2));
params0 = [mu_sym, sigma_sym];
params_fit = lsqcurvefit(gauss_model, params0, x_empirical, f_empirical);
mu_ls = params_fit(1);
sigma_ls = params_fit(2);
fitted_ls = normpdf(x_empirical, mu_ls, sigma_ls);

% --- Step 4: Store outputs in convenient structure --- %
gfit.mu = mu_ls;
gfit.sig = sigma_ls;
fls.x = x_empirical; 
fls.y = fitted_ls;

end % function end