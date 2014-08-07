function obj = SubsetPatients(obj, patient_ids_to_include, varargin)
% Choose a subset of patient IDs; create patients with NaN features if FeatureSet does
% not already include those patients
% SubsetPatients(obj, patient_ids, varargin)
% 
% INPUTS
% patient_ids_to_include: patient IDs to include; if {}, then do nothing
% 
% PARAMETERS
% missing: if 'error', error if patients are missing; if 'add', add patients with
%  NaN feature values (default: 'add')
% b_verbose (default: false)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('missing', 'add', @(x) ismember(x, {'add', 'error'}));
p.addParamValue('b_verbose', false);
p.parse(varargin{:});

%% Setup
if ischar(patient_ids_to_include)
  patient_ids_to_include = {patient_ids_to_include};
end
patient_ids_to_include = patient_ids_to_include(:);

%% Select subset of patients
missing_patients = setdiff(patient_ids_to_include, obj.PatientIDs);
if ~isempty(missing_patients)
  if strcmp(p.Results.missing, 'add')
    % Add requested patients that are missing from the pipeline data set as rows of NaNs
    obj.FeatureVector = [obj.FeatureVector; nan(length(missing_patients), length(obj.FeatureNames))];
    obj.PatientIDs = [obj.PatientIDs; missing_patients];
    obj = SortPatients(obj);
    
    if p.Results.b_verbose
      fprintf('Added patients %s with NaN features\n', make_comma_separated_list(missing_patients));
    end
  else
    error('The following patients are missing from this FeatureSet object: %s\n', make_comma_separated_list(missing_patients));
  end
end

if ~isempty(patient_ids_to_include)
  patients_to_remove = setdiff(obj.PatientIDs, patient_ids_to_include);
  obj = RemovePatients(obj, patients_to_remove);

  if p.Results.b_verbose
    fprintf('Removed undesired patients %s\n', make_comma_separated_list(patients_to_remove));
  end
end

