function b_is_triple_negative = is_triple_negative(patient_ids)
% Return true for patients who are triple-negative, and false otherwise

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp', 'stat_analysis'));

%% Get clinical data
persistent X X_names patient_ids_clinical
if isempty(X)
  [X, X_names, patient_ids_clinical] = get_clinical_data;
end

if any(~ismember(patient_ids, patient_ids_clinical))
  error('Could not find clinical data for all patients');
end

%% Align patient IDs
assert(issorted(patient_ids_clinical));
assert(issorted(patient_ids));

idx_valid = ismember(patient_ids_clinical, patient_ids);
X = X(idx_valid, :);

%% Determine triple negative status
er_percent = X(:, strcmp(X_names, 'er_percent'));
pr_percent = X(:, strcmp(X_names, 'pr_percent'));

b_is_triple_negative = er_percent <= 5 & pr_percent <= 5;
