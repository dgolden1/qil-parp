function reproduce_pre_chemo_glcm_pcr_results
% Reproduce pre-chemo GLCM results from paper

% By Daniel Golden (dgolden1 at gmail dot com) August 2014

%% Setup
rng('default');
db_path = '/Users/dgolden/Documents/qil/case_studies/parp/parp_db/pre_res_1.5_resized_maps';
db = LoadDB(PARPDB, db_path);

%% Get GLCM features
feature_set = CollectFeatures(db, 'b_glcm', true);

%% Remove some patients who weren't processed for the paper
exclude_patients = [112 113 114];
feature_set = RemovePatients(feature_set, exclude_patients);

%% Assign treatment response
[categories, rcb, patient_ids_out] = get_treatment_response(feature_set.PatientIDs);
feature_set.Response = categories.rcb_pcr;

%% Lasso run
lasso_run = LassoRun(feature_set, [], [], 'mcreps', 20);
