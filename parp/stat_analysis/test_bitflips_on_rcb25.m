function test_bitflips_on_rcb25
% Figure out whether individually flipping the boolean category "RCB > 2.5"
% makes a difference in model output

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
close all;
output_dir = '~/temp/lasso_output_bitflips';

t_start = now;

%% Collect features
[X, X_names, patient_id, rcb, cats] = collect_features('glcm_str', 'pre');

%% Remove existing lasso output images
remove_existing_lasso_output_plots(output_dir);

%% Run Lasso
Y = cats.rcb_gt25;
Y_unique = unique(Y);

% for kk = 1:2
for kk = 34:length(patient_id) + 1
  this_Y = Y;
  
  % Flip the response for this patient; also do the last run without
  % flipping anyone
  if kk <= length(patient_id)
    this_patient_id = patient_id(kk);
    
    if strcmp(Y(kk), Y_unique{1})
      this_Y{kk} = Y_unique{2};
    else
      this_Y{kk} = Y_unique{1};
    end
  else
    this_patient_id = 0;
  end
  
  % Run lasso
  results(kk) = stat_analysis(X, X_names, this_Y, 'RCB > 2.5', 'b_lasso', true);
  
  % Save ROC results
  Y_unique = unique(Y);
  [roc, optimal_pt] = get_roc_info_from_lasso(results(kk).lasso.fitinfo, results(kk).lasso.Y, Y_unique{1});
  auc(kk) = mean(roc.AUC);
  
  output_filename_base = fullfile(output_dir, sprintf('lasso_rcb_gt25_flipped_%03d', this_patient_id));
  sfigure(1); print_trim_png([output_filename_base '_crossval']);
  sfigure(2); print_trim_png([output_filename_base '_features']);
  sfigure(3); print_trim_png([output_filename_base '_roc']);
  
  fprintf('Flipped patient %d of %d\n', kk, length(patient_id) + 1);
end

output_mat_filename = '~/temp/lasso_bitflips.mat';
save(output_mat_filename);
fprintf('Saved %s in %s\n', output_mat_filename, time_elapsed(t_start, now));
