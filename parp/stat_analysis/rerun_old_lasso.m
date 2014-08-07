function rerun_old_lasso(run_filename)
% Reprint results from a prior lasso run
% rerun_old_lasso(run_filename)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
close all;

output_dir = '~/temp/lasso_output';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

pathstr = fileparts(run_filename);
if isempty(pathstr)
  % Allow run_filename to be given without the full path
  run_filename = fullfile(qilcasestudyroot, 'parp', 'stat_analysis_runs', run_filename);
end

roc = [];
optimal_pt = [];
load(run_filename);

fprintf('Running with %d features on %d patients\n', size(X, 2), length(patient_id));

lasso_category_map = get_lasso_pretty_name_map;
lasso_fieldname_vec = fieldnames(results);

%% Remove existing lasso output images
remove_existing_lasso_output_plots(output_dir);

%% Loop over lasso runs
for kk = 1:length(lasso_fieldname_vec)
  close all;
  
  this_lasso_results = results.(lasso_fieldname_vec{kk}).lasso;
  
  b = this_lasso_results.b;
  Y = this_lasso_results.Y;
  fitinfo = this_lasso_results.fitinfo;
  Y_name = lasso_category_map(lasso_fieldname_vec{kk});
  mcreps = this_lasso_results.fitinfo.mcreps;
  lasso_filename_prefix = lasso_fieldname_vec{kk};
  
  % Calculate some relevant errors
  if strcmp(lasso_fieldname_vec{kk}, 'rcb_cont')
    lasso_type_str = 'lasso';
    
    min_error = fitinfo.MSE(fitinfo.IndexMinMSE);
    min_plus_1SE_error = fitinfo.MSE(fitinfo.Index1SE);
    null_error = fitinfo.MSE(end);
  else
    lasso_type_str = 'lassoglm';
    
    Y_positive_class_label = get_positive_class_label(Y);
    Y_bino = strcmp(Y, Y_positive_class_label);

    min_error = fitinfo.Deviance(fitinfo.IndexMinDeviance);
    min_plus_1SE_error = fitinfo.Deviance(fitinfo.Index1SE);
    null_error = fitinfo.Deviance(end);

    % Get ROC results
    [roc, optimal_pt] = get_roc_info_from_lasso(fitinfo, Y, Y_positive_class_label);
  end
  
  
  % Print chosen features
  lasso_print_results(b, fitinfo, X, X_names, Y_name, mcreps, lasso_type_str, min_error, min_plus_1SE_error, null_error, roc, optimal_pt, []);

  % Plot
  lasso_make_plots(b, fitinfo, Y_name, lasso_type_str, min_error, min_plus_1SE_error, null_error, [], roc, optimal_pt);
  
  % Save plots
  save_fig(1, fullfile(output_dir, sprintf('lasso_%s_crossval', lasso_filename_prefix)));
  save_fig(2, fullfile(output_dir, sprintf('lasso_%s_features', lasso_filename_prefix)));
  
  if strcmp(lasso_type_str, 'lassoglm')
    save_fig(3, fullfile(output_dir, sprintf('lasso_%s_roc', lasso_filename_prefix)));
  end
end

function save_fig(h, output_filename)

sfigure(h);
print_trim_png(output_filename);
% fprintf('Saved %s.png\n', output_filename);

% sfigure(h);
% print('-dpdf', output_filename);
% fprintf('Saved %s.pdf\n', output_filename);
