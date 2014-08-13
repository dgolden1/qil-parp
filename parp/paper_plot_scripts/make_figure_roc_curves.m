function make_figure_roc_curves
% Make ROC curves for some well-performing models for each category

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;

addpath(fullfile(danmatlabroot, 'parp', 'stat_analysis'));
stat_analysis_run_dir = '/Users/dgolden/Documents/qil/case_studies/tnbc_stat_analysis_runs';
output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');

%% Choose roc curves to plot
curves = struct('filename', [], 'field_to_plot', []);

this_idx = 1;
curves(this_idx).filename = 'stat_analysis_run_2012_10_23_1006_glcm_post.mat';
curves(this_idx).field_to_plot = 'rcb_pcr';

this_idx = this_idx + 1;
curves(this_idx).filename = 'stat_analysis_run_2012_10_04_1615_glcm_pre_and_birads.mat';
curves(this_idx).field_to_plot = 'rcb_gt25';

this_idx = this_idx + 1;
curves(this_idx).filename = 'stat_analysis_run_2012_10_23_1006_glcm_post.mat';
curves(this_idx).field_to_plot = 'rcb_gt25';

this_idx = this_idx + 1;
curves(this_idx).filename = 'stat_analysis_run_2012_10_16_0950_clinical_no_ki67_nodes_and_tumor.mat';
curves(this_idx).field_to_plot = 'nodes';

this_idx = this_idx + 1;
curves(this_idx).filename = 'stat_analysis_run_2012_10_15_1606_glcm_and_birads_nodes_and_tumor.mat';
curves(this_idx).field_to_plot = 'nodes';

this_idx = this_idx + 1;
curves(this_idx).filename = 'stat_analysis_run_2012_10_15_1606_glcm_and_birads_nodes_and_tumor.mat';
curves(this_idx).field_to_plot = 'nodes_and_tumor';

%% Plot them
for kk = 1:length(curves)
  load(fullfile(stat_analysis_run_dir, curves(kk).filename));
  this_field_to_plot = curves(kk).field_to_plot;

  this_results = results.(this_field_to_plot).lasso;
  [roc, optimal_pt] = get_roc_info_from_lasso(this_results.fitinfo, this_results.Y, get_positive_class_label(this_results.Y));
  plot_roc_lasso(roc, optimal_pt, strrep(this_field_to_plot, '_', ' '), 'avg_by_roc');
  axis equal;
  axis([0 1 0 1]);
  
  paper_print(sprintf('raw_roc_%d_%s', kk, this_field_to_plot), 8, 2, output_dir);
end
