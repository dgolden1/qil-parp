function feature_set = get_birads_features
% Get lesion morphological features determined by Jafi on July 17 and July
% 25, 2012

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Load XLS data

xls_filename = fullfile(qilsoftwareroot, 'parp', 'PARP Lesion Locations.xlsx');
xls_sheetname = 'Morphological Categories';

if ~exist(xls_filename, 'file')
  error('%s not found', xls_filename);
end

% Load from saved .mat file, if the .mat file is newer than the XLS file
% mat_filename = fullfile(qilcasestudyroot, 'tnbc_jafi_birads_categories', 'tnbc_lesion_birads_categories.mat');
% if exist(mat_filename, 'file')
%   d_xls = dir(xls_filename);
%   d_mat = dir(mat_filename);
%   if d_mat.datenum > d_xls.datenum
%     load(mat_filename, 'feature_set');
%     return;
%   end
% end

% Otherwise, read the XLS file
[num txt raw] = xlsread(xls_filename, xls_sheetname);

%% Remove Comment column
assert(strcmp(txt{1,end}, 'Comment') && strcmp(raw{1,end}, 'Comment'));
txt = txt(:,1:end-1);
raw = raw(:, 1:end-1);

%% Get patient IDs
patient_id_raw = raw(2:end, 1);

%% Get feature names
X_label_matrix_names = txt(1,2:end);
X_label_matrix_names = strrep(X_label_matrix_names, 'BI-RADS ', ''); % The BI-RADS prefix is appended as part of creating the FeatureSet later

%% Get feature values
X_label_matrix_orig = txt(2:end, 2:end);

% Delete patients with blank feature values
idx_valid = ~any(strcmp(X_label_matrix_orig, ''), 2) & cellfun(@(x) ~ischar(x) && isfinite(x), patient_id_raw);
patient_id = cell2mat(patient_id_raw(idx_valid));
X_label_matrix = X_label_matrix_orig(idx_valid, :);

% Append column names to labels
% for kk = 1:length(X_label_matrix_names)
%   X_label_matrix(:, kk) = cellfun(@(x) [X_label_matrix_names{kk} ' ' x], X_label_matrix_orig(:, kk), 'UniformOutput', false);
% end

[X, X_names] = label_to_dummy(X_label_matrix, X_label_matrix_names);

feature_set = FeatureSet(X, patient_id, X_names, [], 'BI-RADS');

%% Remove extra dummy variables that represent mass/non-mass
birads_non_mass = GetValuesByFeature(feature_set, 'bi_rads_mass_shape_none');
fs_birads_non_mass = FeatureSet(birads_non_mass, patient_id, 'BI-RADS Non-Mass', [], '');
features_to_remove = feature_set.FeatureNames(~cellfun(@isempty, regexp(feature_set.FeatureNames, 'bi_rads_.*_none', 'once')));
feature_set = RemoveFeatures(feature_set, features_to_remove);
feature_set = [feature_set, fs_birads_non_mass];

%% Save for later
% save(mat_filename, 'feature_set');
% fprintf('Saved %s\n', mat_filename);

1;
