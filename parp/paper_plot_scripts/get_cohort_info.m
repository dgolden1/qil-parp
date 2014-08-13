function get_cohort_info
% Get general info about the cohort

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
close all;

addpath(fullfile(qilsoftwareroot, 'parp'));
addpath(fullfile(qilsoftwareroot, 'parp', 'stat_analysis'));

%% Get patient IDs
% [~, ~, patient_id_birads] = collect_features('b_birads', true);
% patient_id_pre = get_processed_patient_list('pre').';
% patient_id_post = get_processed_patient_list('post').';
% patient_id_all = union(patient_id_birads, union(patient_id_pre, patient_id_post));
% 
% % Get rid of patients without RCB
% si = get_spreadsheet_info(patient_id_all);
% rcb = [si.rcb_value];
% patient_id_all = patient_id_all(isfinite(rcb));
% 
% % Get rid of excluded patients
% patient_id_excluded = get_excluded_patient_list.';
% patient_id_all = patient_id_all(~ismember(patient_id_all, patient_id_excluded));

%% Get clinical data
[X, X_names, patient_id] = get_clinical_data;

% Exclude patients for whom we don't have RCB data; patients excluded for
% other reasons are not returned by get_rcb_table_data
rcbs = get_rcb_table_data([], true);
idx_valid = ismember(patient_id, [rcbs.patient_id]);

% Exclude patients with NaN features other than Ki67
idx_valid = idx_valid & ~isnan(X(:, strcmp(X_names, 'cycles_of_treatment_received_ 4 (all possible cycles)')));

% Choose only BRCA positive patients
idx_name_brca1_neg = cellfun(@(x) ~isempty(strfind(x, 'brca1')) & ~isempty(strfind(x, 'Negative')), X_names);
idx_name_brca2_neg = cellfun(@(x) ~isempty(strfind(x, 'brca2')) & ~isempty(strfind(x, 'Negative')), X_names);
idx_patient_brca1_pos = X(:,idx_name_brca1_neg) == 0;
idx_patient_brca2_pos = X(:,idx_name_brca2_neg) == 0;

% idx_valid = ismember(patient_id, patient_id_all);
X = X(idx_valid, :);
patient_id = patient_id(idx_valid);

%% Quantize ER and PR status
idx_unknown_er = isnan(X(:,strcmp(X_names, 'er_percent')));
X(:,end+1) = X(:,strcmp(X_names, 'er_percent')) > 5;
X_names{end+1} = 'er_status_positive';
X(:,end+1) = X(:,strcmp(X_names, 'er_percent')) <= 5;
X_names{end+1} = 'er_status_negative';
X(idx_unknown_er,end-1:end) = nan;

idx_unknown_pr = isnan(X(:,strcmp(X_names, 'pr_percent')));
X(:,end+1) = X(:,strcmp(X_names, 'pr_percent')) > 5;
X_names{end+1} = 'pr_status_positive';
X(:,end+1) = X(:,strcmp(X_names, 'pr_percent')) <= 5;
X_names{end+1} = 'pr_status_negative';
X(idx_unknown_pr,end-1:end) = nan;

%% Print categories
label_categories = {'stage_ia_iiia', 'TNM_T', 'TNM_N', 'cycles_of_treatment_received', 'initial_histology', 'tumor_grade', ...
  'er_status', 'pr_status', 'her2_by_ihc', 'her2_fish_result', 'brca1_result', 'brca2_result'};

fprintf('\n');

for kk = 1:length(label_categories)
  this_column_idx = cellfun(@(x) ~isempty(strfind(x, label_categories{kk})), X_names);
  
  labels(kk).name = (label_categories{kk});
  these_column_names = strrep(X_names(this_column_idx), [(label_categories{kk}) '_'], ''); % Ditch the variable name; just keep the value
  labels(kk).values = dummy_to_label(X(:, this_column_idx), these_column_names);
  
  labels(kk).values(cellfun(@isempty, labels(kk).values)) = {'Unknown'};
  
  % labels.(label_categories{kk}) = dummy_to_label(X(:, this_column_idx), X_names(this_column_idx));
  
  % Print summary
  fprintf('%s:\n', labels(kk).name);
  nominal_print_summary(labels(kk).values, 'ids', patient_id, 'b_percent', true);
  fprintf('\n');
end

%% Print non-categories
idx_continuous = find(~all(X == 0 | X == 1 | isnan(X), 1));

for kk = 1:length(idx_continuous)
  this_column_idx = idx_continuous(kk);
  fprintf('%s\n', X_names{this_column_idx});
  fprintf('Mean:      %0.3G\n', nanmean(X(:,this_column_idx)));
  fprintf('Median:    %0.3G\n', nanmedian(X(:,this_column_idx)));
  fprintf('STD:       %0.3G\n', nanstd(X(:,this_column_idx)));
  fprintf('# Unknown: %d\n', sum(isnan(X(:,this_column_idx))));
  fprintf('\n');
end

1;
