function MakeForestPlot(lasso_runs, run_names, h_fig)
% h = MakeForestPlot(lasso_runs)
% 
% Make a forest plot with the ouputs of many lasso models

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

low_vals = [lasso_runs.Sensitivity];
high_vals = [lasso_runs.Specificity];
dot_vals = [lasso_runs.AUC];
junk_idx = [lasso_runs.AUC] < 0.5;

forest_plot(low_vals, high_vals, dot_vals, run_names, 'legend_names', {'Sensitivity', 'Specificity', 'AUC'}, 'junk_idx', junk_idx)
xlim([0 1]);
