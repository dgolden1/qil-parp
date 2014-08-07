function lasso_make_plots(b, fitinfo, Y_name, lasso_type_str, min_error, min_plus_1SE_error, null_error, h_fig, roc, optimal_pt)
% Make some lasso and ROC plots

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Make lasso plots
if ~exist('h_fig', 'var') || length(h_fig) < 1
  figure;
else
  clf(h_fig(1));
end
h_ax = gca;

lassoPlot(b, fitinfo,'PlotType','CV', 'Parent', h_ax);
set(findobj(gcf, 'type', 'line'), 'markersize', 8);
title(sprintf('Predict %s (min error: %G, +1SE: %G, null: %G)', Y_name, min_error, min_plus_1SE_error, null_error));
increase_font

if ~exist('h_fig', 'var') || length(h_fig) < 2
  figure;
else
  clf(h_fig(2));
end
h_ax = gca;

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log', 'Parent', h_ax)
title(sprintf('Predict %s (min error: %G, +1SE: %G, null: %G)', Y_name, min_error, min_plus_1SE_error, null_error));
increase_font(gcf, 14);

%% Make ROC plot
if strcmp(lasso_type_str, 'lassoglm') && exist('roc', 'var') && ~isempty(roc) && ...
    exist('optimal_pt', 'var') && ~isempty(optimal_pt)
  
  if length(h_fig) >= 3
    roc_fig = h_fig(3);
  else
    roc_fig = [];
  end
  
  plot_roc_lasso(roc, optimal_pt, Y_name, 'avg_by_roc', roc_fig);
end
