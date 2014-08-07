function feature_set = CollectFeatures(obj, varargin)
% Collect a bunch of different categories of features
% 
% feature_set = collect_features(varargin)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

%% Parse input arguments
p = inputParser;
p.addParamValue('jj_str', 'none'); % Can be all, none, old, or one of ktrans, kep, ve, wash_in, wash_out, auc
p.addParamValue('clinical_str', 'none'); % Can be 'all', 'all_but_ki67', 'none', or a cell array of features to include
p.addParamValue('b_glcm', false); % 4 built-in GLCM features
p.addParamValue('b_glcm_full', false); % 13 of 14 GLCM features
p.addParamValue('b_histogram', false);
p.addParamValue('b_man_char_v1', false);
p.addParamValue('b_man_char_v2', false);
p.addParamValue('b_birads', false);
p.addParamValue('b_jafis_patterns_of_response', false);
p.addParamValue('num_fake_features', 0)
p.parse(varargin{:});
jj_str = p.Results.jj_str;
clinical_str = p.Results.clinical_str;
b_man_char_v1 = p.Results.b_man_char_v1;
b_man_char_v2 = p.Results.b_man_char_v2;
b_birads = p.Results.b_birads;
b_glcm = p.Results.b_glcm;
b_glcm_full = p.Results.b_glcm_full;
b_histogram = p.Results.b_histogram;
b_jafis_patterns_of_response = p.Results.b_jafis_patterns_of_response;
num_fake_features = p.Results.num_fake_features;

% Didn't specify any features, select all features
b_any_features = false;
fn = fieldnames(p.Results);
for kk = 1:length(fn)
  this_param = p.Results.(fn{kk});
  if isempty(this_param) || (ischar(this_param) && strcmp(this_param, 'none')) || (isscalar(this_param) && (isnumeric(this_param) || islogical(this_param)) && ~this_param)
    continue;
  else
    b_any_features = true;
    break;
  end
end

if ~b_any_features
  % Earlier, I selected all features if user chose no features; but this is
  % silly. Just throw an error
  error('No features selected');
end

%% Load different data sets
feature_set = repmat(FeatureSet, 0);

fprintf('Chosen features:\n');

% Jiajing's pipeline features
if ~strcmp(jj_str, 'none')
  fprintf('Jiajing''s features: %s\n', jj_str);
  error('Not yet implemented');
  feature_set = [feature_set, get_jiajings_pipeline_features('img_type', jj_str)];
end

% Clinical features
if ~strcmp(clinical_str, 'none')
  feature_set = [feature_set, collect_clinical_data(clinical_str)];
end

% GLCM and related features
if b_glcm
  fprintf('GLCM features\n');
  glcm_feature_set = get_image_features(obj, 'glcm', 'GLCM', @GetFeatureGLCM);
  glcm_feature_set = prepend_chemo_phase_to_feature_names(obj.PreOrPostChemo, glcm_feature_set);
  feature_set = [feature_set, glcm_feature_set];
end

% Full set of GLCM features
if b_glcm_full
  fprintf('GLCM Full features\n');
  glcm_full_feature_set = get_image_features(obj, 'glcm_full', 'GLCM Full', @GetFeatureGLCMFull);
  glcm_full_feature_set = prepend_chemo_phase_to_feature_names(obj.PreOrPostChemo, glcm_full_feature_set);
  feature_set = [feature_set, glcm_full_feature_set];
end

% Histogram features
if b_histogram
  fprintf('Histogram features\n');
  hist_feature_set = get_image_features(obj, 'hist', 'Histogram', @GetFeatureHist);
  hist_feature_set = prepend_chemo_phase_to_feature_names(obj.PreOrPostChemo, hist_feature_set);
  feature_set = [feature_set, hist_feature_set];
end

% Manually-categorized lesion features from subtraction images and PK maps
if b_man_char_v1
  fprintf('Dan''s manually characterized features v1\n');
  feature_set = [feature_set, get_man_cat_lesion_features];
end

% Manually-categorized lesion features 2nd round (multiple categories per
% lesion)
if b_man_char_v2
  fprintf('Dan''s manually characterized features v2\n');
  feature_set = [feature_set, get_man_cat_lesion_features_v2];
end

% Jafi's BI-RADS features
if b_birads
  fprintf('BI-RADS features\n');
  feature_set = [feature_set, get_birads_features];
end

% Jafi's patterns of response
if b_jafis_patterns_of_response
  fprintf('Jafi''s patterns of response\n');
  feature_set = [feature_set, get_jafis_patterns_of_response];
end

% Some fake features
if num_fake_features > 0
  fprintf('%s fake features\n', num_fake_features);

  if isempty(feature_set)
    patient_ids = [];
  else
    patient_ids = feature_set.PatientIDs;
  end
  feature_set = [feature_set, get_fake_features(num_fake_features, patient_ids)];
end

%% Remove features that are constant
feature_set = RemoveConstantFeatures(feature_set);

%% Get rid of patients who are excluded or have invalid features
fprintf('Beginning with %d patients\n', length(feature_set.PatientIDs));

% Remove excluded patients
excluded_patient_list = get_excluded_patient_list;
feature_set = RemovePatients(feature_set, excluded_patient_list, true, '(excluded)');

% Remove patients with invalid features
feature_set = RemoveInvalidPatients(feature_set);

%% Get RCB and RCB categories
[categories, rcb, patient_ids] = get_treatment_response(feature_set.PatientIDs);
ids_to_remove = feature_set.PatientIDs(~ismember(feature_set.PatientIDs, patient_ids));
feature_set = RemovePatients(feature_set, ids_to_remove, true, 'with insufficient RCB information');

fprintf('Running with %d features on %d patients\n', length(feature_set.FeatureNames), length(feature_set.PatientIDs));

1;

function feature_set = get_image_features(obj, feature_name, feature_pretty_name, feature_fun)
%% Function: get image features and save them

if isempty(obj.CommonPixelSpacing)
  error('Property CommonPixelSpacing is unset; common patient resolution is required to get image features');
end

filename = fullfile(obj.Dirname, sprintf('features_%s.mat', feature_name));

% If the PARPDB hasn't changed since we last saved the features, just load the
% saved features
if exist(filename, 'file')
  d = dir(filename);
  if d.datenum > obj.GetDatabaseModifyDate
    load(filename, 'feature_set');
    fprintf('Loaded %s\n', filename);
    return;
  end
end

% Otherwise, determine the features from scratch
feature_set = BatchFunFeature(obj, @GetFeatureForAllIFs, feature_fun);
feature_set.FeatureCategoryName = feature_name;
feature_set.FeatureCategoryPrettyName = feature_pretty_name;

% And save them
save(filename, 'feature_set');
fprintf('Saved %s\n', filename);

function feature_set = get_man_cat_lesion_features_v2
%% Function: load manually-categorized lesion features version 2

% This was the version where I allowed lesions to fall into multiple
% categories

input_dir = fullfile(qilcasestudyroot, 'parp', 'manual_characterization');
input_filename = fullfile(input_dir, 'manually_categorized_lesions_sub_img_new.mat');
load(input_filename, 'feature_names', 'feature_vals', 'patient_id');

X = feature_vals;

feature_set = FeatureSet(X, patient_id, X_names, [], 'Man Char V2');

function feature_set = get_man_cat_lesion_features
%% Function: Load manually-categorized lesion features

input_dir = fullfile(qilcasestudyroot, 'parp', 'manual_characterization');
categorized_lesion_filenames = {'manually_categorized_lesions_sub_img.mat', ...
                                'manually_categorized_lesions_ktrans.mat', ...
                                'manually_categorized_lesions_kep.mat', ...
                                'manually_categorized_lesions_ve.mat'};
                              
feature_prefixes = {'sub', ...
                    'ktrans', ...
                    'kep', ...
                    've'};
                  
for kk = 1:length(categorized_lesion_filenames)
  this_cl = load(fullfile(input_dir, categorized_lesion_filenames{kk}), 'category', 'patient_id');
  [this_X, this_X_names] = label_to_dummy(this_cl.category);
  [~, sort_idx] = sort(this_cl.patient_id);
  
  % Append prefix to uniquely identify these feature names
  this_X_names = cellfun(@(x) [feature_prefixes{kk} '_' x], this_X_names, 'UniformOutput', false);

  if kk == 1
    patient_id = this_cl.patient_id(sort_idx);
    X = this_X(sort_idx, :);
    X_names = this_X_names(:).';
  else
    assert(isequal(patient_id, sort(this_cl.patient_id)));
    X = [X this_X(sort_idx,:)];
    X_names = [X_names this_X_names(:).'];
  end
end

feature_set = FeatureSet(X, patient_id, X_names, [], 'Man Char V1');

function feature_set = collect_clinical_data(clinical_str)
%% Function: Get clinical data

addpath(fullfile(qilsoftwareroot, 'parp', 'stat_analysis'));

if ischar(clinical_str)
  clinical_str_print = clinical_str;
elseif iscell(clinical_str)
  clinical_str_print = make_comma_separated_list(clinical-str);
end
fprintf('Clinical features: %s\n', clinical_str_print);

clinical_columns_to_exclude = {'her2_by_ihc', 'her2_fish_result'};
if ischar(clinical_str) && strcmp(clinical_str, 'all_but_ki67')
  clinical_columns_to_exclude{end+1} = 'ki67_percent';
  fs_name = 'clinical_no_ki67';
  fs_pretty_name = 'Clinical Excluding Ki67';
elseif iscellstr(clinical_str)
  fs_name = ['clinical_no_' strrep(make_comma_separated_list(clinical_str), ', ', '_')];
  fs_pretty_name = ['Clinical Excluding ' make_comma_separated_list(clinical_str)];
else
  fs_name = 'clinical_all';
  fs_pretty_name = 'Clinical All';
end

[X_clinical, X_names_clinical, patient_id] = get_clinical_data(clinical_columns_to_exclude);

% Include only a subset of the variables if requested
if iscell(clinical_str)
  for kk = 1:length(X_names_clinical)
    b_include(kk) = any(cellfun(@(x) ~isempty(strfind(X_names_clinical{kk}, x)), clinical_str));
  end
  X_clinical = X_clinical(:, b_include);
  X_names_clinical = X_names_clinical(b_include);
elseif ischar(clinical_str) && ~ismember(clinical_str, {'all', 'all_but_ki67'})
  b_include = strcmp(X_names_clinical, clinical_str);
  X_clinical = X_clinical(:, b_include);
  X_names_clinical = X_names_clinical(b_include);
end

feature_set = FeatureSet(X_clinical, patient_id, X_names_clinical, [], fs_name, fs_pretty_name);

function feature_set = get_fake_features(num_fake_features, patient_ids)
%% Function: Generate fake features

if ~exist('patient_ids', 'var') || isempty(patient_ids)
  num_patients = 40;
  si = get_spreadsheet_info;
  patient_ids = [si(1:num_patients).study_id].';
else
  num_patients = length(patient_ids);
end

fprintf('%s fake features\n', num_fake_features);
X = randn(num_patients, num_fake_features);
X_names = {};
for kk = 1:num_fake_features
  X_names{kk} = sprintf('fake%04d', kk);
end

feature_set = FeatureSet(X, patient_ids, X_names, [], 'Fake');

function feature_set = prepend_chemo_phase_to_feature_names(str_pre_or_post_chemo, feature_set)
% Prepend the words 'pre' or 'post' to the feature names as appropriate

switch str_pre_or_post_chemo
  case 'pre'
    prepend_str = 'pre_chemo';
    prepend_pretty_str = 'Pre-chemo';
  case 'post'
    prepend_str = 'post_chemo';
    prepend_pretty_str = 'Post-chemo';
end

feature_set = PrependStrToFeatureNames(feature_set, prepend_str, prepend_pretty_str);
feature_set.FeatureCategoryName = [prepend_str '_' feature_set.FeatureCategoryName];
feature_set.FeatureCategoryPrettyName = [prepend_pretty_str ' ' feature_set.FeatureCategoryPrettyName];
