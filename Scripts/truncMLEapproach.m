% Your data (observed only above threshold a)
% data = your_data_vector;
a = min(data);  % known lower truncation threshold

% Negative log-likelihood function for truncated Gaussian
trunc_negloglik = @(p) -sum(...
    log(normpdf(data, p(1), p(2))) - ...
    log(1 - normcdf(a, p(1), p(2))) ...
);

% Initial guesses [mu0, sigma0]
mu0 = mean(data);
sigma0 = std(data);
p0 = [mu0, sigma0];

% Lower bound: sigma > 0
lb = [-Inf, 1e-6];
ub = [Inf, Inf];

% Optimization
options = optimset('Display','iter','TolX',1e-6);
p_hat = fmincon(trunc_negloglik, p0, [], [], [], [], lb, ub, [], options);

mu_trunc = p_hat(1);
sigma_trunc = p_hat(2);

fprintf('Truncated MLE fit:\n  mu = %.4f\n  sigma = %.4f\n', mu_trunc, sigma_trunc);

x_vals = linspace(min(data)-1, max(data)+1, 1000);
pdf_fit = normpdf(x_vals, mu_trunc, sigma_trunc);

% Plot
figure;
histogram(data, 'Normalization', 'pdf', 'DisplayName', 'Observed Data');
hold on;
plot(x_vals, pdf_fit, 'r-', 'LineWidth', 2, 'DisplayName', 'Truncated Gaussian Fit');
xline(a, '--k', 'DisplayName', 'Truncation Threshold');
legend;
title('Truncated MLE Gaussian Fit');
xlabel('Value');
ylabel('Probability Density');
