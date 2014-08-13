function make_figure_forest_results
% Make a figure showing lasso results in a forest plot

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;
clear;

addpath(fullfile(qilsoftwareroot, 'parp'));

% output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');
output_dir = '~/temp';

%% Plot
fig_width = 12;
post_process_fcn = @(x) set(findobj(x, '-property', 'linewidth'), 'linewidth', 1.5);

PARPDB.BatchPlotLassoPaperResults;

sfigure(1);
paper_print('raw_lasso_forest_rcb_pcr', fig_width, 2, output_dir, post_process_fcn);
sfigure(2);
paper_print('raw_lasso_forest_rcb_25', fig_width, 2, output_dir, post_process_fcn);

sfigure(3);
paper_print('raw_lasso_forest_tumor', fig_width, 2, output_dir, post_process_fcn);
sfigure(4);
paper_print('raw_lasso_forest_nodes', fig_width, 2, output_dir, post_process_fcn);
sfigure(5);
paper_print('raw_lasso_forest_tumor_and_nodes', fig_width, 2, output_dir, post_process_fcn);
