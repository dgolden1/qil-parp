function [feature_set, rcb, categories] = collect_features(varargin)
% Collect a bunch of different categories of features
% 
% [feature_set, rcb, categories] = collect_features(varargin)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

%% Parse input arguments
p = inputParser;
p.addParamValue('jj_str', 'none'); % Can be all, none, old, or one of ktrans, kep, ve, wash_in, wash_out, auc
p.addParamValue('clinical_str', 'none'); % Can be 'all', 'all_but_ki67', 'none', or a cell array of features to include
p.addParamValue('glcm_str', 'none'); % Can be 'pre', 'post', 'both', 'both_and_diff', or 'none'
p.addParamValue('histogram_str', 'none'); % Can be 'pre', 'post', 'both' or 'none'
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
glcm_str = p.Results.glcm_str;
histogram_str = p.Results.histogram_str;
b_jafis_patterns_of_response = p.Results.b_jafis_patterns_of_response;
num_fake_features = p.Results.num_fake_features;

% Didn't specify any features, select all features
b_any_features = false;
fn = fieldnames(p.Results);
for kk = 1:length(fn)
  this_param = p.Results.(fn{kk});
  if isempty(this_param) || (ischar(this_param) && strcmp(this_param, 'none')) || (isscalar(this_param) && ~this_param)
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

% For backwards compatibility, from when glcm_str was boolean and true
% meant 'pre' features only
if islogical(glcm_str)
  if glcm_str
    glcm_str = 'pre';
  else
    glcm_str = 'none';
  end
end

%% Load different data sets
feature_set = repmat(FeatureSet, 0);

fprintf('Chosen features:\n');

% Jiajing's pipeline features
if ~strcmp(jj_str, 'none')
  fprintf('Jiajing''s features: %s\n', jj_str);
  feature_set = [feature_set, get_jiajings_pipeline_features('img_type', jj_str)];
end

% Clinical features
if ~strcmp(clinical_str, 'none')
  feature_set = [feature_set, collect_clinical_data(clinical_str)];
end

% GLCM and related features
if ~strcmp(glcm_str, 'none')
  fprintf('GLCM features: %s\n', glcm_str);
  feature_set = [feature_set, get_glcm_model_inputs(glcm_str)];
end

% Histogram features
if ~strcmp(histogram_str, 'none')
  fprintf('Histogram features: %s\n', histogram_str);
  
  if any(strcmp({'both', 'pre'}, histogram_str))
    feature_set = [feature_set, batch_get_histogram_features('pre')];
  end
  if any(strcmp({'both', 'post'}, histogram_str))
    feature_set = [feature_set, batch_get_histogram_features('post')];
  end
  
  feature_set.FeatureCategoryName = sprintf('Histogram %s', histogram_str);
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

if ischar(clinical_str)
  clinical_str_print = clinical_str;
elseif iscell(clinical_str)
  clinical_str_print = '';
  for kk = 1:(length(clinical_str) - 1)
    clinical_str_print = [clinical_str_print clinical_str{kk} ', '];
  end
  clinical_str_print = [clinical_str_print clinical_str{end}];
end
fprintf('Clinical features: %s\n', clinical_str_print);

clinical_columns_to_exclude = {'her2_by_ihc', 'her2_fish_result'};
if ischar(clinical_str) && strcmp(clinical_str, 'all_but_ki67')
  clinical_columns_to_exclude{end+1} = 'ki67_percent';
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

feature_set = FeatureSet(X_clinical, patient_id, X_names_clinical, [], 'clinical');

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
