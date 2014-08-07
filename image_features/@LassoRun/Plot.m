function Plot(obj, varargin)
% Make some lasso and ROC plots
% Plot(obj, 'param', value, ...)
% 
% PARAMETERS
% roc_plot_type: one of 'avg_by_roc', 'avg_by_cost' or 'all_curves' (default:
%  'avg_by_roc')
% b_clear_existing: clear existing plots (default: true)
% b_save_plots: (default: true)
% h_fig: (default: [])

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('roc_plot_type', 'avg_by_roc');
p.addParamValue('b_clear_existing', true);
p.addParamValue('b_save_plots', true);
p.addParamValue('h_fig', []);
p.parse(varargin{:});

%% Setup
if p.Results.b_clear_existing
  close all;
end

%% Lasso CV plot
if length(p.Results.h_fig) < 1
  h(1) = figure;
else
  clf(p.Results.h_fig(1));
  h(1) = p.Results.h_fig(1);
end
h_ax = gca;

lassoPlot(obj.b, obj.fitinfo,'PlotType','CV', 'Parent', h_ax);
set(findobj(gcf, 'type', 'line'), 'markersize', 8);
title(sprintf('Predict %s (min error: %G, +1SE: %G, null: %G)', obj.YName, obj.MinError, obj.MinPlus1SEError, obj.NullError));
if strcmp(obj.Type, 'cox')
  ylabel('Partial Likelihood Deviance');
end
increase_font

%% Lasso Lambda plot
if length(p.Results.h_fig) < 2
  h(2) = figure;
else
  clf(p.Results.h_fig(2));
  h(2) = p.Results.h_fig(2);
end
h_ax = gca;

lassoPlot(obj.b, obj.fitinfo, 'PlotType', 'Lambda', 'xscale', 'log', 'Parent', h_ax)
title(sprintf('Predict %s (min error: %G, +1SE: %G, null: %G)', obj.YName, obj.MinError, obj.MinPlus1SEError, obj.NullError));
increase_font(gcf, 14);

%% ROC plot
if strcmp(obj.Type, 'binomial')
  if length(p.Results.h_fig) < 3
    h(3) = figure;
  else
    h(3) = p.Results.h_fig(3);
  end
  
  plot_roc_lasso(obj.ROC, obj.YName, 'avg_by_roc', h(3));
end

%% For Cox runs: Kaplan-Meir Plot stratified by linear predictor
if strcmp(obj.Type, 'cox')
  if length(p.Results.h_fig) < 3
    h(3) = figure;
    b_new_fig = true; % If true, figure will be resized by plot_survival_by_sextile
  else
    h(3) = p.Results.h_fig(3);
    b_new_fig = false;
  end
  
  plot_survival_by_sextile(obj, h(3), b_new_fig);
  % plot_survival_by_linear_predictor(obj, h(3));
end

%% Save
if p.Results.b_save_plots
  plot_output_dir = '~/temp/lasso_output';
  if ~exist(plot_output_dir, 'dir')
    mkdir(plot_output_dir);
  end

  Y_name_sanitized = sanitize_struct_fieldname(obj.YName);
  sfigure(h(1));
  plot_crossval_filename = fullfile(plot_output_dir, sprintf('lasso_%s_crossval.png', Y_name_sanitized));
  print_trim_png(plot_crossval_filename);
  fprintf('Saved %s\n', plot_crossval_filename);
  
  sfigure(h(2));
  plot_features_filename = fullfile(plot_output_dir, sprintf('lasso_%s_features.png', Y_name_sanitized));
  print_trim_png(plot_features_filename);
  fprintf('Saved %s\n', plot_features_filename);
  
  if length(h) >= 3
    sfigure(h(3));
    if strcmp(obj.Type, 'cox')
      fig_3_suffix = 'lin_pred_survival';
    elseif strcmp(obj.Type, 'binomial')
      fig_3_suffix = 'roc';
    end
    plot_roc_filename = fullfile(plot_output_dir, sprintf('lasso_%s_%s.png', Y_name_sanitized, fig_3_suffix));
    print_trim_png(plot_roc_filename);
    fprintf('Saved %s\n', plot_roc_filename);
  end
end

function plot_roc_lasso(ROC, Y_name, str_plot_type, h_fig)
%% Function: Make ROC plot from lasso regression results
% 
% str_plot_type can be one of 'avg_by_roc', 'avg_by_cost' or 'all_curves'

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
  clf(h_fig);
end

switch str_plot_type
  case 'avg_by_roc'
    roc_std_plot_x = [ROC.X_common fliplr(ROC.X_common)];
    roc_std_plot_y = [ROC.Y_ci_low fliplr(ROC.Y_ci_high)];
    
    area(roc_std_plot_x, roc_std_plot_y, 'facecolor', [1 1 1]*0.8);
    hold on;
    plot(ROC.X_common, ROC.Y_mean, 'k', 'linewidth', 2);
    [x_opt, y_opt] = get_roc_optimal_pt(ROC.X_common, ROC.Y_mean);
    plot(x_opt, y_opt, 'o', 'color', [0 0.5 0], 'markerfacecolor', [0 0.5 0], 'markersize', 8);
    1;
  case 'avg_by_cost'
    roc_std_plot_x = [ROC.X_ci_low_by_cost(:).' fliplr(ROC.X_ci_high_by_cost(:).')];
    roc_std_plot_y = [ROC.Y_ci_low_by_cost(:).' fliplr(ROC.Y_ci_high_by_cost(:).')];

    area(roc_std_plot_x, roc_std_plot_y, 'facecolor', [1 1 1]*0.8);
    hold on;
    plot(ROC.X_mean_by_cost, ROC.Y_mean_by_cost, 'k', 'linewidth', 2)
  case 'all_curves'  
    colororder = lines(length(ROC.X));
    for kk = 1:length(ROC.X)
      stairs(ROC.X{kk}, ROC.Y{kk}, 'color', colororder(kk,:), 'linewidth', 2);
      hold on
    end
    plot(ROC.X_common, ROC.Y_mean, 'k', 'linewidth', 4)
end

xlabel('1 - Specificity');
ylabel('Sensitivity');
grid on;
axis equal;
axis([0 1 0 1]);

title(sprintf('Predict %s AUC = %0.2f+/-%0.2f, Sens=%0.2f+/-%0.2f, Spec=%0.2f+/-%0.2f', Y_name, mean(ROC.AUC), std(ROC.AUC), ...
  mean(ROC.opt_sensitivity), std(ROC.opt_sensitivity), mean(ROC.opt_specificity), std(ROC.opt_specificity)));

increase_font;

1;

function plot_survival_by_linear_predictor(obj, survival_fig)
%% Function: plot survival curves stratified by cross-validated linear predictor variable
% Only applicable for Cox model

if length(obj.fitinfo.linear_predictors) > 1
  error('How do I plot this with multiple Monte Carlo repetitions?');
end

sfigure(survival_fig);
h_ax = axes;

linear_predictors = cell2mat(obj.fitinfo.linear_predictors);

idx_lin_pred_low = linear_predictors <= median(linear_predictors);
times_low = [obj.Y(idx_lin_pred_low).time];
b_censored_low = strcmp({obj.Y(idx_lin_pred_low).event}, 'Censored');
times_high = [obj.Y(~idx_lin_pred_low).time];
b_censored_high = strcmp({obj.Y(~idx_lin_pred_low).event}, 'Censored');

sfigure(survival_fig);
h_low = plot_survival(times_low, b_censored_low, 'h_ax', h_ax, 'color', 'b');
h(1) = h_low(1);

if ~isempty(times_high)
  h_high = plot_survival(times_high, b_censored_high, 'h_ax', h_ax, 'color', 'r');
  h(2) = h_high(1);
  legend_str = {'Low Lin Pred', 'High Lin Pred'};
else
  legend_str = {'Net Survival'};
end

xlabel('Time');
legend(h, legend_str, 'Location', 'SouthWest');

if ~all(linear_predictors == 0)
  pvals = cell2mat(obj.fitinfo.pval);
  if length(pvals) == 1
    pval_str = sprintf(': %g', pvals(1));
  else
    pval_str = sprintf(' mean: %g, range: [%g, %g]', mean(pvals), min(pvals), max(pvals));
  end

  title(sprintf('Cross-validated linear predictor Cox PH p-val%s\n', pval_str));
else
  title('Model failed; all linear predictors == 0');
end

increase_font;

function plot_survival_by_sextile(obj, survival_fig, b_new_fig)
%% Function: plot survival curves stratified by cross-validated linear predictor variable
% Only applicable for Cox model

if length(obj.fitinfo.linear_predictors) > 1
  error('How do I plot this with multiple Monte Carlo repetitions?');
end

sfigure(survival_fig);

if var(obj.fitinfo.sextiles{1}) == 0
  sextile_strat_vec = {{true(size(obj.Y)), false(size(obj.Y))}};
  sextile_strat_name_vec = {'Net survival'};
  plot_title_vec = {sprintf('Model failed; all linear predictors == 0 (n=%d)', length(obj.Y))};
  b_model_failed = true;
else
  % Make two plots; one stratified by sextile <=3 and > 3 (by the cross-validated median),
  % and one stratified by sextile <=2 and > 4 (upper and lower thirds)
  sextile_strat_vec = {{obj.fitinfo.sextiles{1} <=3, obj.fitinfo.sextiles{1} > 3}, ...
                       {obj.fitinfo.sextiles{1} <= 2, obj.fitinfo.sextiles{1} > 4}};
  sextile_strat_name_vec = {'Upper/lower halves', 'Upper/lower thirds'};
  plot_title_vec = {sprintf('Strata=median, Log-rank p=%0.2g', obj.fitinfo.logrank_p{1}.p_median), ...
                    sprintf('Strata=thirds, Log-rank p=%0.2g', obj.fitinfo.logrank_p{1}.p_thirds)};
  b_model_failed = false;
  
  if b_new_fig
    figure_grow(gcf, 2, 1);
  end
end

for kk = 1:length(sextile_strat_vec)
  h_ax = subplot(1, length(sextile_strat_vec), kk);

  this_sextile_strat = sextile_strat_vec{kk};
  
  % Stratify by this sextile stratification method
  idx_low = this_sextile_strat{1};
  idx_high = this_sextile_strat{2};
  if ~any(idx_low) || ~any(idx_high)
    % Ensure that, in case there's only one strata, it's the "low" strata
    idx_low = idx_low | idx_high;
    idx_high = false(size(idx_high));
  end
  
  times_low = [obj.Y(idx_low).time];
  b_censored_low = strcmp({obj.Y(idx_low).event}, 'Censored');
  times_high = [obj.Y(idx_high).time];
  b_censored_high = strcmp({obj.Y(idx_high).event}, 'Censored');

  h_low = plot_survival(times_low, b_censored_low, 'h_ax', h_ax, 'color', 'b');
  h(1) = h_low(1);

  if any(idx_low) && any(idx_high)
    h_high = plot_survival(times_high, b_censored_high, 'h_ax', h_ax, 'color', 'r');
    h(2) = h_high(1);
    
    legend_str = {sprintf('Low Lin Pred (n=%d)', sum(idx_low)), sprintf('High Lin Pred (n=%d)', sum(idx_high))};
    legend(h, legend_str, 'Location', 'SouthWest');
  end

  xlabel('Time');
  title(plot_title_vec{kk});
end

if ~b_model_failed
  pvals = cell2mat(obj.fitinfo.pval);
  if length(pvals) == 1
    pval_str = sprintf('=%0.2g', pvals(1));
  else
    pval_str = sprintf(' mean: %0.2g, range: [%0.2g, %0.2g]', mean(pvals), min(pvals), max(pvals));
  end

  title_arbitrary_pos(sprintf('Cox p%s\n', pval_str), 'y', 0.86);
end
increase_font;

1;
