function BatchRunModelsForPaper
% Run a bunch of lasso models for my 2012-2013 PARP paper

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Setup
output_dir = fullfile(qilcasestudyroot, 'parp', 'stat_analysis_runs', 'paper_rev_2');

%% Load databases
pdb_pre = PARPDB('pre', 'common_res_1.5_resized_maps');
pdb_post = PARPDB('post', 'common_res_1.5_resized_maps');

%% Set up feature arguments
feature_args_pre = {{'clinical_str', 'all'}
                    {'clinical_str', 'all_but_ki67'}
                    {'b_glcm', true}
                    {'b_jafis_patterns_of_response', true}
                    {'b_birads', true}
                    {'b_glcm', true, 'b_birads', true}
                    };
pre_suffixes = {'clinical_all'
                'clinical_all_but_ki67'
                'glcm_pre'
                'patterns_of_response'
                'birads'
                'glcm_pre_and_birads'};
  
feature_args_post = {{'b_glcm', true}};
post_suffixes = {'glcm_post'};

feature_args_combined = {{'b_glcm', true}};
combined_suffixes = {'glcm_both'};

%% Run pre-chemo models
for kk = 1:length(feature_args_pre)
  [b_output_file_exists, output_filename] = output_file_exists(output_dir, pre_suffixes{kk});
  if b_output_file_exists
    fprintf('Output file %s exists, skipping...\n', output_filename);
    continue;
  end
  
  RunLassoModel(pdb_pre, feature_args_pre{kk}, [], 'output_dir', output_dir, ...
    'output_filename', 'lasso_run', 'suffix', pre_suffixes{kk});
end

%% Run post-chemo models
for kk = 1:length(feature_args_post)
  [b_output_file_exists, output_filename] = output_file_exists(output_dir, post_suffixes{kk});
  if b_output_file_exists
    fprintf('Output file %s exists, skipping...\n', output_filename);
    continue;
  end
  
  RunLassoModel(pdb_post, feature_args_post{kk}, [], 'output_dir', output_dir, ...
    'output_filename', 'lasso_run', 'suffix', post_suffixes{kk});
end

%% Run combined models
for kk = 1:length(feature_args_combined)
  [b_output_file_exists, output_filename] = output_file_exists(output_dir, combined_suffixes{kk});
  if b_output_file_exists
    fprintf('Output file %s exists, skipping...\n', output_filename);
    continue;
  end
  
  PARPDB.RunLassoModelMultiDB(pdb_pre, pdb_post, feature_args_combined{kk}, feature_args_combined{kk}, [], ...
    'output_dir', output_dir, 'output_filename', 'lasso_run', 'suffix', combined_suffixes{kk});
end

function [b_output_file_exists, output_filename] = output_file_exists(output_dir, suffix)
% Return true if output file exists

output_filename = fullfile(output_dir, sprintf('lasso_run_%s.mat', suffix));
b_output_file_exists = exist(output_filename, 'file');
