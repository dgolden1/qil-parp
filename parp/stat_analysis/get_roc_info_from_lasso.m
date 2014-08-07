function [roc, optimal_pt] = get_roc_info_from_lasso(fitinfo, Y, Y_positive_class_label)
% Get ROC information from the fitinfo struct from a lassoglm run with
% multiple Monte Carlo repetitions
% (specifically, Dan's modified lassoglm, called my_lassoglm)
% [roc, optimal_pt] = get_roc_info_from_lasso(fitinfo, Y, Y_positive_class_label)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'image_features'));

%% Get individual ROC curves
for kk = 1:size(fitinfo.predictedValues, 1)
  this_predicted_values = fitinfo.predictedValues{kk, fitinfo.Index1SE};
  [roc.X{kk}, roc.Y{kk}, roc.T{kk}, roc.AUC(kk), roc.optpt{kk}] = perfcurve(Y, this_predicted_values, Y_positive_class_label);

  [roc.cost_X(:, kk), roc.cost_Y(:, kk)] = cost_curve_from_roc(roc.X{kk}, roc.Y{kk});
  
  % Make X values unique by moving them a little bit
  % Save original X values for debugging
  roc.X_orig = roc.X;
  idx_dx_eq_0 = [false; diff(roc.X{kk}) == 0];
  roc.X{kk}(idx_dx_eq_0) = roc.X{kk}(idx_dx_eq_0) + 1e-4*(1:sum(idx_dx_eq_0)).';
end

%% Combine by averaging ROC curves
n_common_pts = 100;

roc.X_common = linspace(0, 1, n_common_pts);
for kk = 1:length(roc.Y)
  roc.Y_common(kk,:) = interp1(roc.X{kk}, roc.Y{kk}, roc.X_common, 'linear');
end
roc.Y_mean = mean(roc.Y_common, 1);

if size(roc.Y_common, 1) == 1
  roc.Y_std = 0;
else
  roc.Y_std = std(roc.Y_common, 1);
end

% Plot this using area() to show bounds of ROC
roc.Y_ci_high = roc.Y_mean + roc.Y_std;
roc.Y_ci_low = roc.Y_mean - roc.Y_std;

%% Combine by averaging in cost-space
roc.Y_mean_cost = mean(roc.cost_Y, 2);
roc.Y_std_cost = std(roc.cost_Y, [], 2);
roc.Y_ci_high_cost = roc.Y_mean_cost + roc.Y_std_cost;
roc.Y_ci_low_cost = roc.Y_mean_cost - roc.Y_std_cost;

[roc.X_mean_by_cost, roc.Y_mean_by_cost] = roc_from_cost_curve(roc.cost_X(:,1), roc.Y_mean_cost);
[roc.X_ci_high_by_cost, roc.Y_ci_high_by_cost] = roc_from_cost_curve(roc.cost_X(:,1), roc.Y_ci_high_cost);
[roc.X_ci_low_by_cost, roc.Y_ci_low_by_cost] = roc_from_cost_curve(roc.cost_X(:,1), roc.Y_ci_low_cost);

%% Sensitivity and specificity of the optimal point
optptmat = cell2mat(roc.optpt.');
optimal_pt.sensitivity = optptmat(:,2);
optimal_pt.specificity = 1 - optptmat(:,1);
