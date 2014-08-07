function PlotZScores(obj)
% Plot the zscores of the feature vector to look for patients that are potentially
% outliers 

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Plot feature map
X_norm = zscore(obj.FeatureVector);

figure;
imagesc(X_norm.');
xlabel('Patient ID');
caxis(max(abs(caxis))*[-1 1]);
colormap hotcold;
c = colorbar;
ylabel(c, 'Z Score');

set(gca, 'xtick', 1:length(obj.PatientIDs), 'xticklabel', obj.PatientIDs, 'ytick', 1:length(obj.FeaturePrettyNames), 'yticklabel', obj.FeaturePrettyNames);
figure_grow(gcf, 2);
title('Feature map');

zoom yon;

%% Plot average outlier amount
figure
bar(sqrt(mean(X_norm.^2, 2)))
set(gca, 'xtick', 1:length(obj.PatientIDs), 'xticklabel', obj.PatientIDs)
figure_grow(gcf, 2, 1);
grid on;
ylabel('RMS outlier value');
increase_font
