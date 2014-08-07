function plot_roc_lasso(roc, optimal_pt, Y_name, str_plot_type, h_fig)
% Make ROC plot from lasso regression results
% 
% str_plot_type can be one of 'avg_by_roc', 'avg_by_cost' or 'all_curves'

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
if ~exist('str_plot_type', 'var') || isempty(str_plot_type)
  % str_plot_type = 'avg_by_roc';
  % str_plot_type = 'avg_by_cost';
  str_plot_type = 'all_curves';
end

%% Plot
if ~exist('h_fig', 'var') || isempty(h_fig)
  figure;
else
  clf(h_fig(3));
end

switch str_plot_type
  case 'avg_by_roc'
    roc_std_plot_x = [roc.X_common fliplr(roc.X_common)];
    roc_std_plot_y = [roc.Y_ci_low fliplr(roc.Y_ci_high)];
    
    area(roc_std_plot_x, roc_std_plot_y, 'facecolor', [1 1 1]*0.8);
    hold on;
    plot(roc.X_common, roc.Y_mean, 'k', 'linewidth', 2)
  case 'avg_by_cost'
    roc_std_plot_x = [roc.X_ci_low_by_cost(:).' fliplr(roc.X_ci_high_by_cost(:).')];
    roc_std_plot_y = [roc.Y_ci_low_by_cost(:).' fliplr(roc.Y_ci_high_by_cost(:).')];

    area(roc_std_plot_x, roc_std_plot_y, 'facecolor', [1 1 1]*0.8);
    hold on;
    plot(roc.X_mean_by_cost, roc.Y_mean_by_cost, 'k', 'linewidth', 2)
  case 'all_curves'  
    colororder = lines(length(roc.X));
    for kk = 1:length(roc.X)
      stairs(roc.X{kk}, roc.Y{kk}, 'color', colororder(kk,:), 'linewidth', 2);
      hold on
    end
    plot(roc.X_common, roc.Y_mean, 'k', 'linewidth', 4)
end

xlabel('1 - Specificity');
ylabel('Sensitivity');
grid on;
axis([0 1 0 1]);

title(sprintf('Predict %s AUC = %0.2f+/-%0.2f, Sens=%0.2f+/-%0.2f, Spec=%0.2f+/-%0.2f', Y_name, mean(roc.AUC), std(roc.AUC), ...
  mean(optimal_pt.sensitivity), std(optimal_pt.sensitivity), mean(optimal_pt.specificity), std(optimal_pt.specificity)));

increase_font;

1;
