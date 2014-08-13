function analyze_patterns_of_response_results
% Analyze the patterns of response results to figure out why it didn't work

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id$

close all;

load /Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/paper_rev_2/lasso_run_patterns_of_response.mat

lasso_run = lasso_runs(3); % Just look at residual tumor
rcb_struct = get_rcb_table_data(lasso_runs(1).ThisFeatureSet.PatientIDs, true);

[predicted_values, dev, cv_pred_se, cv_pred_mean, cv_dev] = GetPredictedValuesFull(lasso_run);

b_tumor = strcmp(lasso_run.Y, 'Residual Tumor');

labels = dummy_to_label(lasso_run.ThisFeatureSet.FeatureVector, lasso_run.ThisFeatureSet.FeaturePrettyNames);

labels = strrep(labels, 'Patterns of Response  ', '');

label_order = {
    'RESOLUTION'
    'REGRESSION WITH FRAGMENTATION'
    'REGRESSION WITHOUT FRAGMENTATION'
    'NO CHANGE'
    'PROGRESSION'
    };
  
labels = title_case(labels);
label_order = title_case(label_order);
  
colors = jet(7);
colors(2:3,:) = [];

figure;
figure_grow(gcf, 2, 1);
subplot(1, 2, 1)
pie_plot(labels(b_tumor), 'label_order', label_order, 'colors', colors, 'h_ax', gca);
text(0, 0, sprintf('Tumor (n=%d)', sum(b_tumor)), 'backgroundcolor', 'w', 'horizontalalignment', 'center');

subplot(1, 2, 2);
pie_plot(labels(~b_tumor), 'label_order', label_order(1:3), 'colors', colors, 'h_ax', gca);
text(0, 0, sprintf('No Tumor (n=%d)', sum(~b_tumor)), 'backgroundcolor', 'w', 'horizontalalignment', 'center');

increase_font;

b_tumor_by_mri = ~strcmpi(labels, 'Resolution');

sensitivity = sum(b_tumor & b_tumor_by_mri)/sum(b_tumor);
specificity = sum(~b_tumor & ~b_tumor_by_mri)/sum(~b_tumor);

fprintf('Sensitivity = %0.2f\nSpecificity = %0.2f\n', sensitivity, specificity);

paper_print('raw_patterns_of_response_sensitivity', 14, 2, fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images'));

1;