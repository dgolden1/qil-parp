% An example of running a LassoRun with arbitrary features

%% Setup
close all;
clear
rng('default');

db_path = '/Users/dgolden/Documents/qil/case_studies/parp/parp_db/pre_res_1.5_resized_maps';
db = LoadDB(PARPDB, db_path);

% Hard code in patient ids; some patients in DB don't have response defined
% patient_ids = GetPatientList(db);
patient_ids = [1 2 3 4 5 6 7 8 9 13 16 17 19 20 21 22 24 25 27 28 31 34 35 36 38 40 41 45 46 47 48 49 50 52 53 54 58 60 63 64 65 68 69 70 71 101 103 104 105 106 108 110 111]';

%% Get response
[categories, rcb, patient_ids_out] = get_treatment_response(patient_ids);

%% Create fake features
noise = randn(size(categories.tumor))*0.5;
feature_good = strcmp(categories.tumor, 'Residual Tumor');
features_noise = randn(length(categories.tumor), 2);
features = [feature_good + noise, features_noise];

feature_names = cellfun(@(x) sprintf('fake%s', x), num2cell(1:size(features, 2)), 'UniformOutput', false);
feature_pretty_names = feature_names;
feature_category_name = 'fake';
feature_category_pretty_name = 'fake';

feature_set = FeatureSet(features, patient_ids, feature_names, feature_pretty_names, feature_category_name, feature_category_pretty_name);

%% Assign response
feature_set.Response = categories.tumor;

%% Run LassoRun
lasso_run = LassoRun(feature_set);
