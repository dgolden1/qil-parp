function debug_find_outliers
% Look for patients that are consistently outliers in my feature vector, in
% case one or two patients are screwing everything up

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
close all;

addpath(fullfile(qilsoftwareroot, 'parp'));


%% Collect features
[X, X_names, patient_id] = collect_features('glcm_str', 'pre');

%% Plot feature map
X_norm = zscore(X);

figure;
imagesc(X_norm.');
xlabel('Patient ID');
caxis(max(abs(caxis))*[-1 1]);
colormap hotcold;
c = colorbar;
ylabel(c, 'Z Score');

set(gca, 'xtick', 1:length(patient_id), 'xticklabel', patient_id, 'ytick', 1:length(X_names), 'yticklabel', X_names);
figure_grow(gcf, 2);
title('Feature map');

zoom yon;

%% Plot average outlier amount
figure
plot(sqrt(mean(X_norm.^2, 2)), 'linewidth', 2)
set(gca, 'xtick', 1:length(patient_id), 'xticklabel', patient_id)
figure_grow(gcf, 2, 1);
grid on;
ylabel('RMS outlier value');
increase_font
