function gfit = psr_fitGaussian(spka)
%% psr_fitGaussian Fits Gaussian function to spikes amplitudes and estimates percent missing in actual distribution
%
% INPUTS:
%   spka - vector of spike amplitudes
%
% OUTPUTS:
%   gfit - structure with following fields:
%           - mu: mean for fitted Gaussian
%           - sig: standard deviation for fitted Gaussian
%
% Written by Scott Kilianski
% Updated on 2025-06-05
% ------------------------------------------------------------ %
%% ---- Function Body Here ---- %%%
plotFlag = 1; 
% nbins = 1000; % number of bins
% [vals, be] = histcounts(spka,nbins,'Normalization','pdf');

% Using KDE to estimate mean of underlying Gaussian
[fVals, xVals] = ksdensity(spka); % kernel density estimate
% dx = xVals(2) - xVals(1);  % Assumes uniform spacing
% mu_kde = sum(xVals .* fVals) * dx;
% split_point = mu_kde; % uses KDE-based mean to find center of distribution


% bc = be(1:end-1)+diff(be); % bin centers
[~, maxI] = max(fVals); % get peak of distribution
split_point = xVals(maxI);  % or use mode(data)

% ---- Step 2: Extract right half and mirror it around the split ----
right_half = spka(spka >= split_point);
mirrored = 2*split_point - right_half;

% ---- Step 3: Combine original and mirrored to make symmetric distribution ----
symmetric_data = [right_half; mirrored];

% ---- Step 4: Fit a Gaussian to the symmetrized distribution ----
pd_sym = fitdist(symmetric_data, 'Normal');
mu_sym = pd_sym.mu;
sigma_sym = pd_sym.sigma;

x_vals = linspace(min(symmetric_data), max(symmetric_data), 1000);
% fitted_pdf = normpdf(x_vals, mu_sym, sigma_sym);

[f_empirical, x_empirical] = ksdensity(symmetric_data);

% Fit Gaussian to KDE using lsqcurvefit
gauss_model = @(p, x) normpdf(x, p(1), p(2));
params0 = [mu_sym, sigma_sym];

params_fit = lsqcurvefit(gauss_model, params0, x_empirical, f_empirical);
mu_ls = params_fit(1);
sigma_ls = params_fit(2);


% --- Plot --- %
if plotFlag
    fitted_ls = normpdf(x_vals, mu_ls, sigma_ls);
    cf = figure("Position", [850, 120, 1037, 902],...
        'Visible','off');
    subplot(1,5, 2:5);
    % plot(x_empirical, f_empirical, 'b-', 'LineWidth', 2, 'DisplayName', 'Kernel Density');
    % histogram(symmetric_data,'Normalization','pdf');
    histogram(spka,'Normalization','pdf')
    hold on;
    plot(x_vals, fitted_ls, 'r--', 'LineWidth', 2, 'DisplayName', 'Fitted Gaussian');
    legend;
    title('Fitted Gaussian vs. Actual Data');
end

gfit.mu = mu_ls;
gfit.sig = sigma_ls;
end % function end