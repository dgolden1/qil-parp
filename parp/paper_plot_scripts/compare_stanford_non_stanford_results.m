function compare_stanford_non_stanford_results
% Compare model deviance between Stanford and non-Stanford patients

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id$

%% Setup
close all;

%% Get number of time points for each patient
stats_filename = '~/temp/parp_comparisons/parpdb_stats.mat';
if ~exist(stats_filename, 'file')
  stats_pre = GetSomeImageStats(PARPDB('pre'));
  stats_post = GetSomeImageStats(PARPDB('post'));
  save(stats_filename, 'stats_pre', 'stats_post');
  fprintf('Saved %s\n', stats_filename);
else
  load(stats_filename, 'stats_pre', 'stats_post');
  fprintf('Loaded %s\n', stats_filename);
end

%% Pre-chemo GLCM
run_filenames = {
                 '/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/paper_rev_2/lasso_run_glcm_pre.mat'
                 '/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/paper_rev_2/lasso_run_birads.mat'
                 '/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/paper_rev_2/lasso_run_glcm_post.mat'
                 };
for jj = 1:length(run_filenames)
  load(run_filenames{jj});
  
  for kk = 1:length(lasso_runs)
    if lasso_runs(kk).AUC >= 0.6 && kk ~= 2
      % time_res_boxplot(lasso_runs(kk));
      scatter_num_time_points(lasso_runs(kk), stats_pre, stats_post);
    end
  end
end

function time_res_boxplot(lasso_run)
%% Function: make one box plot

t_start = now;

if isempty(strfind(lasso_run.ThisFeatureSet.FeatureCategoryName, 'post_chemo'))
  str_pre_or_post_chemo = 'pre';
else
  str_pre_or_post_chemo = 'post';
end

b_stanford = is_stanford_scan(lasso_run.ThisFeatureSet.PatientIDs, str_pre_or_post_chemo);
str(b_stanford) = {sprintf('Stanford (n=%d)', sum(b_stanford))};
str(~b_stanford) = {sprintf('Not Stanford (n=%d)', sum(~b_stanford))};

[predicted_values, dev, cv_pred_se, cv_pred_mean, cv_dev] = lasso_run.GetPredictedValuesFull;
cv_dev_mean = mean(cv_dev, 2);

figure;
boxplot(cv_dev_mean, str, 'notch', 'on');
ylabel('Deviance');
plot_title = sprintf('%s --> %s', lasso_run.ThisFeatureSet.FeatureCategoryPrettyName, lasso_run.YName);
title(plot_title);
increase_font;

p = ranksum(cv_dev_mean(b_stanford), cv_dev_mean(~b_stanford));

output_filename = fullfile('/Users/dgolden/temp/parp_stanford_nonstanford', sprintf('stanford_nonstanford_%s--%s.png', ...
  sanitize_struct_fieldname(lasso_run.ThisFeatureSet.FeatureCategoryPrettyName), sanitize_struct_fieldname(lasso_run.YName)));
print_trim_png(output_filename);
fprintf('Saved %s in %s\n', output_filename, time_elapsed(t_start, now));

function scatter_num_time_points(lasso_run, stats_pre, stats_post)
%% Function: look at effect of number of time points

if isempty(strfind(lasso_run.ThisFeatureSet.FeatureCategoryName, 'post_chemo'))
  stats = stats_pre;
  str_pre_or_post_chemo = 'pre';
else
  stats = stats_post;
  str_pre_or_post_chemo = 'post';
end

b_stanford = is_stanford_scan(lasso_run.ThisFeatureSet.PatientIDs, str_pre_or_post_chemo);

[predicted_values, dev, cv_pred_se, cv_pred_mean, cv_dev] = lasso_run.GetPredictedValuesFull;
cv_dev_mean = mean(cv_dev, 2);

stats_idx = ismember([stats.patient_id], lasso_run.ThisFeatureSet.PatientIDs);
num_time_points = [stats(stats_idx).num_time_points];
dt = [stats(stats_idx).dt];
pixel_spacing = [stats(stats_idx).pixel_spacing];
slice_thickness = [stats(stats_idx).slice_thickness];

cv_dev_mean(~ismember(lasso_run.ThisFeatureSet.PatientIDs, [stats.patient_id])) = [];
b_stanford(~ismember(lasso_run.ThisFeatureSet.PatientIDs, [stats.patient_id])) = [];

measures = {num_time_points, dt, pixel_spacing, slice_thickness};
measure_names = {'Num time points', 'dt', 'Original pixel spacing', 'Slice thickness'};

figure;
figure_grow(gcf, 2);

for kk = 1:length(measures)
  subplot(2, 2, kk);
  plot(measures{kk}(b_stanford), cv_dev_mean(b_stanford), 'ro', measures{kk}(~b_stanford), cv_dev_mean(~b_stanford), 'bo');
  % plot(measures{kk}, cv_dev_mean, 'o');
  xlabel(measure_names{kk});
  ylabel('Mean CV Deviance');
  grid on;
  
  if kk == 1
    plot_title = sprintf('%s --> %s', lasso_run.ThisFeatureSet.FeatureCategoryPrettyName, lasso_run.YName);
    title(plot_title);
  end
end

increase_font;

output_filename = fullfile('/Users/dgolden/temp/parp_comparisons', sprintf('scatter_%s--%s.png', ...
  sanitize_struct_fieldname(lasso_run.ThisFeatureSet.FeatureCategoryPrettyName), sanitize_struct_fieldname(lasso_run.YName)));
print_trim_png(output_filename);
fprintf('Saved %s\n', output_filename);

1;