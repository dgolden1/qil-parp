function ROC_struct = GetROC(obj)
% Get ROC information from a lassoglm run with multiple Monte Carlo repetitions
% (specifically, Dan's modified lassoglm, called my_lassoglm)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Get individual ROC curves
for kk = 1:size(obj.fitinfo.predictedValues, 1)
  this_predicted_values = obj.fitinfo.predictedValues{kk, obj.fitinfo.Index1SE};
  [ROC_struct.X{kk}, ROC_struct.Y{kk}, ROC_struct.T{kk}, ROC_struct.AUC(kk), ROC_struct.optpt{kk}] = perfcurve(obj.Y, this_predicted_values, obj.YPositiveClassLabel);

  [ROC_struct.cost_X(:, kk), ROC_struct.cost_Y(:, kk)] = cost_curve_from_roc(ROC_struct.X{kk}, ROC_struct.Y{kk});
  
  % Make X values unique by moving them a little bit
  % Save original X values for debugging
  ROC_struct.X_orig = ROC_struct.X;
  idx_dx_eq_0 = [false; diff(ROC_struct.X{kk}) == 0];
  ROC_struct.X{kk}(idx_dx_eq_0) = ROC_struct.X{kk}(idx_dx_eq_0) + 1e-4*(1:sum(idx_dx_eq_0)).';
end

%% Combine by averaging ROC curves
n_common_pts = 100;

ROC_struct.X_common = linspace(0, 1, n_common_pts);
for kk = 1:length(ROC_struct.Y)
  ROC_struct.Y_common(kk,:) = interp1(ROC_struct.X{kk}, ROC_struct.Y{kk}, ROC_struct.X_common, 'linear');
end
ROC_struct.Y_mean = mean(ROC_struct.Y_common, 1);

if size(ROC_struct.Y_common, 1) == 1
  ROC_struct.Y_std = 0;
else
  ROC_struct.Y_std = std(ROC_struct.Y_common, 1);
end

% Plot this using area() to show bounds of ROC
ROC_struct.Y_ci_high = ROC_struct.Y_mean + ROC_struct.Y_std;
ROC_struct.Y_ci_low = ROC_struct.Y_mean - ROC_struct.Y_std;

%% Combine by averaging in cost-space
ROC_struct.Y_mean_cost = mean(ROC_struct.cost_Y, 2);
ROC_struct.Y_std_cost = std(ROC_struct.cost_Y, [], 2);
ROC_struct.Y_ci_high_cost = ROC_struct.Y_mean_cost + ROC_struct.Y_std_cost;
ROC_struct.Y_ci_low_cost = ROC_struct.Y_mean_cost - ROC_struct.Y_std_cost;

[ROC_struct.X_mean_by_cost, ROC_struct.Y_mean_by_cost] = roc_from_cost_curve(ROC_struct.cost_X(:,1), ROC_struct.Y_mean_cost);
[ROC_struct.X_ci_high_by_cost, ROC_struct.Y_ci_high_by_cost] = roc_from_cost_curve(ROC_struct.cost_X(:,1), ROC_struct.Y_ci_high_cost);
[ROC_struct.X_ci_low_by_cost, ROC_struct.Y_ci_low_by_cost] = roc_from_cost_curve(ROC_struct.cost_X(:,1), ROC_struct.Y_ci_low_cost);

%% Sensitivity and specificity of the optimal point
optptmat = cell2mat(ROC_struct.optpt.');
ROC_struct.opt_sensitivity = optptmat(:,2);
ROC_struct.opt_specificity = 1 - optptmat(:,1);

function [x_roc, y_roc] = roc_from_cost_curve(x_cc, y_cc, b_plot)
%% Function: Get an ROC curve from a cost curve
% See "What ROC Curves Can't Do (and Cost Curves Can)" by Drummont and
% Holte

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
if ~exist('b_plot', 'var') || isempty(b_plot)
  b_plot = false;
end

%% Estimate cost curve lines
vertices = find([true; abs(diff(y_cc, 2)) > 1e-4; true]);

% Find a line between each vertex
for kk = 1:(length(vertices) - 1)
  lines(kk).slope = diff(y_cc(vertices([kk+1, kk])))/diff(x_cc(vertices([kk+1, kk])));
  lines(kk).intercept = y_cc(vertices(kk)) - lines(kk).slope*x_cc(vertices(kk));
end

slopes = [lines.slope];
intercepts = [lines.intercept];

%% Get ROC coordinates from cost curve lines
x_roc = intercepts;
y_roc = 1 - (intercepts + slopes);

if iscolumn(x_cc)
  x_roc = x_roc(:);
  y_roc = y_roc(:);
end

%% Plot
if b_plot
  figure;
  plot(x_roc, y_roc, 'k-', 'linewidth', 2);
  xlabel('1 - Specificity');
  ylabel('Sensitivity');
  grid on
  increase_font;
end

function [x_cc, y_cc, lines] = cost_curve_from_roc(roc_x, roc_y, b_plot)
%% Function: Get a cost curve based on an ROC curve
% 
% See "What ROC curves can't do (and cost curves can)" by Drummond and Hote
% 2004

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
if ~exist('b_plot', 'var') || isempty(b_plot)
  b_plot = false;
end

%% Compute slopes and intercepts for cost curve lines
for kk = 1:length(roc_x)
  lines(kk).intercept = roc_x(kk);
  lines(kk).slope = 1 - roc_y(kk) - roc_x(kk);
end
intercepts = [lines.intercept];
slopes = [lines.slope];

%% Get cost curve points

% Calculate points for predeterimed x-points; this isn't exact, but I don't
% know of a good way to do it otherwise
n = 100;
x_cc = linspace(0, 1, n).';
x_cc_mat = repmat(x_cc, 1, length(roc_x)); % x-points down rows, roc points (lines) across columns
intercepts_mat = repmat(intercepts, length(x_cc), 1);
slopes_mat = repmat(slopes, length(x_cc), 1);
y_cc_mat = intercepts_mat + slopes_mat.*x_cc_mat;
y_cc = min(y_cc_mat, [], 2);

% Find vertices and delete points that are not vertices
% vertices_idx = [true; abs(diff(y_cc, 2)) > 1/(10*n); true];
% x_cc = x_cc(vertices_idx);
% y_cc = y_cc(vertices_idx);

%% Plot
if b_plot
  plot_cost_curve(lines, x_cc, y_cc);
end

1;
