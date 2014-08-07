function test_cost_curve
% Function to test cost_curve()

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;

rng('default'); % Make results repeatable

n = 100;
x = rand(n, 1);
noise = randn(n, 1)*0.5;
y = x + noise > 0.5;

b = glmfit(x, y, 'binomial');
y_hat = glmval(b, x, 'logit');

% plotconfusion(y.', y_hat.' > 0.5);

%% Get ROC curve
% Get original ROC curve
[roc_x, roc_y] = perfcurve(y, y_hat, true);

% Get ROC curve with unique X and Y
% [roc_x_unique, roc_y_unique] = get_roc_unique(roc_x, roc_y, 'bottom');
roc_x_unique = roc_x;
roc_y_unique = roc_y;

% Plot ROC curve
h_roc = figure;
plot(roc_x, roc_y, 'k-', 'linewidth', 2);
xlabel('1 - Specificity');
ylabel('Sensitivity');
grid on;
increase_font;

%% Get cost curve
b_plot = true;
[cost_x, cost_y, cost_lines] = cost_curve_from_roc(roc_x_unique, roc_y_unique, b_plot);

%% Transform back to ROC curve
[roc_x_reverse, roc_y_reverse] = roc_from_cost_curve(cost_x, cost_y, false);
sfigure(h_roc);
hold on;
plot(roc_x_reverse, roc_y_reverse, 'r-o', 'linewidth', 2);

function [roc_x_unique, roc_y_unique] = get_roc_unique(roc_x, roc_y, str_top_or_bottom)
%% Function: Get ROC curve with unique X and Y

switch str_top_or_bottom
  case 'top'
    % This curve follows the top of the stair-step ROC
    [roc_y_unique, idx_unique_y] = unique(roc_y, 'first');
    roc_x_unique = roc_x(idx_unique_y);
    [roc_x_unique, idx_unique_x] = unique(roc_x_unique, 'last');
    roc_y_unique = roc_y_unique(idx_unique_x);
  case 'bottom'
    % This curve follows the bottom of the stair-step ROC
    [roc_y_unique, idx_unique_y] = unique(roc_y, 'last');
    roc_x_unique = roc_x(idx_unique_y);
    [roc_x_unique, idx_unique_x] = unique(roc_x_unique, 'first');
    roc_y_unique = roc_y_unique(idx_unique_x);
  case 'mid'
    % This curve follows the middle of the stair-step ROC
    roc_x_unique = unique(roc_x);
    roc_y_unique = nan(size(roc_x_unique));
    for kk = 1:length(roc_x_unique)
      this_y = roc_y(roc_x == roc_x_unique(kk));
      roc_y_unique(kk) = min(this_y) + (max(this_y) - min(this_y))/2;
    end
end

1;
