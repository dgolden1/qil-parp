function test_stat_analysis
% Run some test cases on the stat_analysis function

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

%% Test ECDF
% load(fullfile(qilsoftwareroot, 'parp', 'manual_characterization', 'manually_categorized_lesions_sub_img.mat'), ...
%   'category', 'patient_id');
% 
% si = get_spreadsheet_info(patient_id);
% rcb = [si.rcb_value].';
% 
% [X, X_names] = label_to_dummy(category);
% 
% stat_analysis(X, X_names, rcb, 'rcb', 'b_ecdf', true);

%% Test Kolmogorov-Smirnov Matrix
% stat_analysis(X, X_names, rcb, 'rcb', 'b_ks_matrix', true);

%% Test ranksum
% [X, X_names, patient_id] = get_jiajings_pipeline_features;
% si = get_spreadsheet_info(patient_id);
% rcb = [si.rcb_value].';
% 
% output_label = cell(size(rcb));
% output_label(rcb == 0) = {'pCR'};
% output_label(rcb > 0) = {'RCB > 0'};
% 
% stat_analysis(X, X_names, output_label, 'pCR', 'b_ranksum', true);

%% Test Fisher's Exact Test Matrix
load(fullfile(qilsoftwareroot, 'parp', 'manual_characterization', 'manually_categorized_lesions_sub_img.mat'), ...
  'category', 'patient_id');

si = get_spreadsheet_info(patient_id);
rcb = [si.rcb_value].';

idx_valid = isfinite(rcb);
rcb = rcb(idx_valid);
category = category(idx_valid);

output_label = cell(size(rcb));
output_label(rcb == 0) = {'pCR'};
output_label(rcb > 0) = {'RCB > 0'};

[X, X_names] = label_to_dummy(category);

stat_analysis(X, X_names, output_label, 'pCR', 'b_fishers_exact', true);

%% Test boxplot
% stat_analysis(X, X_names, output_label, 'pCR', 'b_boxplots', true);

% load(fullfile(qilsoftwareroot, 'parp', 'manual_characterization', 'manually_categorized_lesions_sub_img.mat'), ...
%   'category', 'patient_id');
% si = get_spreadsheet_info(patient_id);
% rcb = [si.rcb_value].';
% [X, X_names] = label_to_dummy(category);
% 
% stat_analysis(X, X_names, rcb, 'RCB', 'b_boxplots', true);

%% Test plot proportions
% load(fullfile(qilsoftwareroot, 'parp', 'manual_characterization', 'manually_categorized_lesions_sub_img.mat'), ...
%   'category', 'patient_id');
% si = get_spreadsheet_info(patient_id);
% rcb = [si.rcb_value].';
% [X, X_names] = label_to_dummy(category);
% idx_valid = isfinite(rcb);
% 
% rcb = rcb(idx_valid);
% X = X(idx_valid, :);
% 
% output_label = cell(size(rcb));
% output_label(rcb == 0) = {'0 pCR'};
% output_label(rcb > 0) = {'1 RCB > 0'};
% 
% stat_analysis(X, X_names, output_label, 'RCB', 'b_proportion_plots', true);

%% Test continuous response regression and lasso
% [X, X_names, patient_id] = get_jiajings_pipeline_features;
% si = get_spreadsheet_info(patient_id);
% rcb = [si.rcb_value].';
% 
% stat_analysis(X, X_names, rcb, 'RCB', 'b_regression', true, 'b_lasso', true);

%% Test categorical response regression and lasso
% output_label = cell(size(rcb));
% output_label(rcb == 0) = {'0 pCR'};
% output_label(rcb > 0) = {'1 RCB > 0'};
% 
% stat_analysis(X, X_names, output_label, 'RCB', 'b_regression', true, 'b_lasso', false);
