function lasso_runs = RunLassoModelMultiDB(obj_pre, obj_post, feature_param_vals_pre, feature_param_vals_post, response_vec, varargin)
% Run a lasso model with multiple databases (e.g., pre and post) with combined features

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Parse input arguments
% Code copied from PARPDB.RunLassoModel
p = inputParser;
p.addParamValue('suffix', '');
p.addParamValue('output_filename', '');
p.addParamValue('output_dir', fullfile(qilcasestudyroot, 'parp', 'stat_analysis_runs', 'lasso_run_objects'));
p.addParamValue('b_get_lasso_inputs_only', false); % True to return lasso inputs instead of running lasso model
p.parse(varargin{:});

suffix = p.Results.suffix;
if ~isempty(suffix) && suffix(1) ~= '_'
  % Prepend a _ onto the filename suffix
  suffix = ['_' suffix];
end

[pathstr, ~] = fileparts(p.Results.output_filename);
if ~isempty(pathstr)
  % Path is included in filename
  p.Results.output_dir = '';
end


%% Get pre- and post lasso inputs
[feature_set_pre, Y_vec_pre, Y_name_vec, positive_class_label] = ...
  RunLassoModel(obj_pre, feature_param_vals_pre, response_vec, 'b_get_lasso_inputs_only', true, varargin{:});

[feature_set_post] = ...
  RunLassoModel(obj_post, feature_param_vals_post, response_vec, 'b_get_lasso_inputs_only', true, varargin{:});

%% Get common patients
patient_ids_common = intersect(feature_set_pre.PatientIDs, feature_set_post.PatientIDs);
idx_pre_common = ismember(feature_set_pre.PatientIDs, patient_ids_common);
idx_post_common = ismember(feature_set_post.PatientIDs, patient_ids_common);

Y_vec = cellfun(@(x) x(idx_pre_common), Y_vec_pre, 'uniformoutput', false);

%% Combine feature sets
feature_set_pre.FeatureCategoryName = 'pre_chemo_glcm';
feature_set_post.FeatureCategoryName = 'post_chemo_glcm';

% feature_set_pre = PrependStrToFeatureNames(feature_set_pre, 'pre', 'Pre');
% feature_set_post = PrependStrToFeatureNames(feature_set_post, 'post', 'Post');

feature_set_combined = [feature_set_pre, feature_set_post];
feature_set_combined.FeatureCategoryName = 'pre_and_post_chemo_glcm';
feature_set_combined.FeatureCategoryPrettyName = 'Pre- and Post-chemo GLCM';


%% Run analysis
% Code copied from PARPDB.RunLassoModel
for kk = 1:length(Y_vec)
  lasso_runs(kk) = LassoRun(feature_set_combined, Y_vec{kk}, Y_name_vec{kk}, positive_class_label{kk});
end

%% Save features and output for later
% Code copied from PARPDB.RunLassoModel
if isempty(p.Results.output_filename)
  output_filename = sprintf('lasso_run_%s.mat', datestr(now, 'yyyy_mm_dd_HHMM'));
else
  output_filename = p.Results.output_filename;
end

output_full_filename = fullfile(p.Results.output_dir, [output_filename, suffix]);

save(output_full_filename, 'lasso_runs');
fprintf('Saved %s\n', output_full_filename);

1;
