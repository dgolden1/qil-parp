function varargout = RunLassoModel(obj, feature_param_values, response_vec, varargin)
% Run a lasso model with selected features and response
% lasso_runs = RunLassoModel(obj, feature_param_values, response_vec, varargin)
% 
% [feature_set, Y_vec, Y_name_vec, positive_class_label] = RunLassoModel(..., 'b_get_lasso_inputs_only', true)
% 
% Example run to predict residual nodes with no features:
% RunLassoModel(obj, {'jj_str', 'none', 'clinical_str', 'none', 'b_glcm', false, 'b_man_char_v1', false, 'b_man_char_v2', false, 'b_birads', false, 'b_jafis_patterns_of_response', false, 'num_fake_features', 0}, {'nodes'}, 'test')
% 
% response_vec can be any of {'rcb_pcr', 'rcb_gt25', 'nodes', 'tumor', 'tumor_and_nodes'}

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
close all;

addpath(fullfile(qilsoftwareroot, 'parp', 'stat_analysis'));

plot_output_dir = '~/temp/lasso_output';
if ~exist(plot_output_dir, 'dir')
  mkdir(plot_output_dir);
end

%% Parse input arguments
p = inputParser;
p.addParamValue('suffix', '');
p.addParamValue('output_filename', '');
p.addParamValue('output_dir', fullfile(qilcasestudyroot, 'parp', 'stat_analysis_runs', 'lasso_run_objects'));
p.addParamValue('exclude_patients', []);
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

if ~exist('response_vec', 'var') || isempty(response_vec)
  % RCB
  % response_vec = {'rcb_pcr', 'rcb_gt25', 'rcb_2or3', 'rcb_3'};

  % RCB = 0 and RCB > 2.5 only
%   response_vec = {'rcb_pcr', 'rcb_gt25'};

  % Residual tumor and nodes
  % response_vec = {'nodes', 'tumor', 'tumor_and_nodes'};

  % Residual (tumor AND nodes) and RCB > 2.5
  % response_vec = {'tumor_and_nodes', 'rcb_gt25'};
  
  % All the good stuff
  response_vec = {'rcb_pcr', 'rcb_gt25', 'tumor', 'nodes', 'tumor_and_nodes'};
elseif ischar(response_vec)
  response_vec = {response_vec};
end

%% Collect features and response
feature_set = CollectFeatures(obj, feature_param_values{:});
[response_cats, ~, patient_ids_out] = get_treatment_response(feature_set.PatientIDs);

patient_ids_common = intersect(feature_set.PatientIDs, patient_ids_out);
ids_to_remove = feature_set.PatientIDs(~ismember(feature_set.PatientIDs, patient_ids_common));
feature_set = RemovePatients(feature_set, ids_to_remove, true, 'without RCB determined');

idx_remove = ~ismember(patient_ids_out, patient_ids_common);
fn = fieldnames(response_cats);
for kk = 1:length(fn)
  response_cats.(fn{kk})(idx_remove) = [];
end

%% Remove existing lasso output images
remove_existing_lasso_output_plots(plot_output_dir);

%% Prepare analysis
lasso_name_map = get_lasso_pretty_name_map;

Y_vec = {};
Y_name_vec = {};
for kk = 1:length(response_vec)
  Y_vec{kk} = response_cats.(response_vec{kk});
  Y_name_vec{kk} = lasso_name_map(response_vec{kk});
end

for kk = 1:length(Y_vec)
  switch response_vec{kk}
    case 'nodes'
      positive_class_label{kk} = 'Node Pos';
    case 'tumor'
      positive_class_label{kk} = 'Residual Tumor';
    case 'tumor_and_nodes'
      positive_class_label{kk} = 'Tumor and Nodes';
    otherwise
      positive_class_label{kk} = [];
  end
end

%% Possibly, return without running analysis
if p.Results.b_get_lasso_inputs_only
  varargout = {feature_set, Y_vec, Y_name_vec, positive_class_label};
  return;
end

%% Exclude patients based on exclude_patients parameter
patients_to_remove = p.Results.exclude_patients;
if ~isempty(patients_to_remove)
  fprintf('Excluding additional patients by request: %s\n', make_comma_separated_list(patients_to_remove));
  Y_vec{1}(ismember(feature_set.PatientIDs, patients_to_remove)) = [];
  feature_set = RemovePatients(feature_set, patients_to_remove);
  fprintf('Now running on %d patients\n', length(feature_set.PatientIDs));
end

%% Run analysis
for kk = 1:length(Y_vec)
  lasso_runs(kk) = LassoRun(feature_set, Y_vec{kk}, Y_name_vec{kk}, 'y_positive_class_label', positive_class_label{kk});
end

%% Save features and output for later analysis
if isempty(p.Results.output_filename)
  output_filename = sprintf('lasso_run_%s.mat', datestr(now, 'yyyy_mm_dd_HHMM'));
else
  output_filename = p.Results.output_filename;
end

output_full_filename = fullfile(p.Results.output_dir, [output_filename, suffix]);

save(output_full_filename, 'lasso_runs');
fprintf('Saved %s\n', output_full_filename);

varargout{1} = lasso_runs;
