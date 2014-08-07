function batch_run_stat_analysis(feature_param_values, response_vec, filename_suffix)
% Run statistical analyses for lots of my different features
% Input arguments are passed directly to collect_features()
% 
% Example run with no features:
% batch_run_stat_analysis({'jj_str', 'none', 'clinical_str', 'none', 'glcm_str', 'none', 'b_man_char_v1', false, 'b_man_char_v2', false, 'b_birads', false, 'b_jafis_patterns_of_response', false, 'num_fake_features', 0}, 'test')

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
close all;

addpath(fullfile(qilsoftwareroot, 'parp'));

plot_output_dir = '~/temp/lasso_output';
if ~exist(plot_output_dir, 'dir')
  mkdir(plot_output_dir);
end

%% Parse input arguments
if ~exist('filename_suffix', 'var')
  filename_suffix = '';
end
if ~isempty(filename_suffix) && filename_suffix(1) ~= '_'
  % Prepend a _ onto the filename suffix
  filename_suffix = ['_' filename_suffix];
end

if ~exist('response_vec', 'var')
  % RCB
  % response_vec = {'rcb_pcr', 'rcb_gt25', 'rcb_2or3', 'rcb_3'};

  % RCB = 0 and RCB > 2.5 only
%   response_vec = {'rcb_pcr', 'rcb_gt25'};

  % Residual tumor and nodes
  % response_vec = {'nodes', 'tumor', 'tumor_and_nodes'};

  % Residual (tumor AND nodes) and RCB > 2.5
  % response_vec = {'tumor_and_nodes', 'rcb_gt25'};
  
  % All the good stuff
  response_vec = {'rcb_pcr', 'rcb_gt25', 'nodes', 'tumor', 'tumor_and_nodes'};
end

%% Collect features
[feature_set, rcb, cats] = collect_features(feature_param_values{:});

%% Remove existing lasso output images
remove_existing_lasso_output_plots(plot_output_dir);

%% Run analysis
lasso_name_map = get_lasso_pretty_name_map;

Y_vec = {};
Y_name_vec = {};
for kk = 1:length(response_vec)
  Y_vec{kk} = cats.(response_vec{kk});
  Y_name_vec{kk} = lasso_name_map(response_vec{kk});
end

for kk = 1:length(Y_vec)
  results.(response_vec{kk}) = stat_analysis(feature_set, Y_vec{kk}, Y_name_vec{kk}, 'b_lasso', true);
  sfigure(1); print_trim_png(fullfile(plot_output_dir, sprintf('lasso_%s_crossval', response_vec{kk})));
  sfigure(2); print_trim_png(fullfile(plot_output_dir, sprintf('lasso_%s_features', response_vec{kk})));
  if ishandle(3)
    sfigure(3); print_trim_png(fullfile(plot_output_dir, sprintf('lasso_%s_roc', response_vec{kk})));
  end
end

%% Save features and output for later in case I screw up this code
feature_filename = fullfile(qilcasestudyroot, 'parp', 'stat_analysis_runs', ...
  sprintf('stat_analysis_run_%s%s.mat', datestr(now, 'yyyy_mm_dd_HHMM'), filename_suffix));

X = feature_set.FeatureVector;
X_names = feature_set.FeatureNames;
save(feature_filename, 'X', 'X_names', 'rcb', 'patient_id', 'results');
fprintf('Saved %s\n', feature_filename);
