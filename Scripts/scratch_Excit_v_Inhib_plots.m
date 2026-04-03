%% Identify cluster by 
X = [xj,yj];
% X = [bigHLFDUR,bigTTP];

figure;
% fitting gaussian mixed model to 2 clusters
gm = fitgmdist(X, 2); 
idx = cluster(gm, X);

% --- Set up grid --- %
xrange = linspace(0, max(X(:,1)), 200);
yrange = linspace(0, max(X(:,2)), 200);
[xGrid, yGrid] = meshgrid(xrange, yrange);
gridPoints = [xGrid(:), yGrid(:)];

% --- Posterior probabilities --- %
P = posterior(gm, gridPoints);

% Decision boundary = where P1 = P2
diffP = P(:,1) - P(:,2);
diffP = reshape(diffP, size(xGrid));

% --- Plotting --- %
msz = 72;
clr1 = [0.85 0.33 0.10];
scatter(X(idx==1,1), X(idx==1,2), msz, 'filled',...
    'MarkerEdgeColor',clr1,'MarkerFaceColor',clr1,...
    'MarkerFaceAlpha', 0.3);
hold on
clr2 = [0 0.45 0.74];
scatter(X(idx==2,1), X(idx==2,2), msz, 'filled',...
    'MarkerEdgeColor',clr2,'MarkerFaceColor',clr2,...
    'MarkerFaceAlpha', 0.3);

% Boundary line
contour(xGrid, yGrid, diffP, [0 0], 'k', 'LineWidth', 4)

% Optional: density contours
% f = @(x,y) pdf(gm, [x y]);
% ezcontour(f, [min(X(:,1)) max(X(:,1)) min(X(:,2)) max(X(:,2))])

% plot(gm.mu(:,1), gm.mu(:,2), 'kx', 'MarkerSize', 15, 'LineWidth', 3)
xlim([0 0.6])
ylim([0 1.4])