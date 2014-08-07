function values = GetValues(obj, patient_ids, feature_names, b_print)
% Get some values from the FeatureVector
% values = GetValues(obj, patient_ids, feature_names, b_print)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Setup
if ~exist('b_print', 'var') || isempty(b_print)
  b_print = false;
end

obj_patient_ids = patient_id_tostr(obj.PatientIDs);

%% Parse patient ids
if ~exist('patient_ids', 'var') || isempty(patient_ids)
  idx_patients = (1:length(obj_patient_ids)).';
else
  patient_ids = patient_id_tostr(patient_ids);
  idx_patients = find(ismember(obj_patient_ids, patient_ids));
  
  if isempty(idx_patients)
    missing_patient_list = make_comma_separated_list(setdiff(patient_ids, obj_patient_ids));
    error('Patient IDs not found in database: %s', missing_patient_list);
  end
end

%% Parse features
if ~exist('feature_names', 'var') || isempty(feature_names)
  idx_features = 1:length(obj.FeatureNames);
else
  if ischar(feature_names)
    feature_names = {feature_names};
  end
  
  idx_features = find(ismember(obj.FeatureNames, feature_names) | ismember(obj.FeaturePrettyNames, feature_names));
  
  if isempty(idx_features)
    missing_feature_list = make_comma_separated_list(setdiff(feature_names, [obj.FeatureNames, obj.FeaturePrettyNames]));
    error('Features not found in database: %s', missing_feature_list);
  end
end

%% Get values
values = obj.FeatureVector(idx_patients, idx_features);


%% Print
if b_print
  patient_ids_str = obj_patient_ids;
  these_patient_ids = patient_ids_str(idx_patients);
  these_feature_names = obj.FeaturePrettyNames(idx_features);
  
  fprintf('Patients ');
  for kk = 1:(length(these_patient_ids) - 1)
    fprintf('%s, ', these_patient_ids{kk});
  end
  fprintf('%s\n', these_patient_ids{end});
  
  for jj = 1:length(these_feature_names)
    this_feature_idx = idx_features(jj);
    
    fprintf('%s: [', these_feature_names{jj});
    for kk = 1:length(these_patient_ids)
      this_patient_idx = idx_patients(kk);
      
      if kk < length(these_patient_ids)
        fprintf('%G, ', obj.FeatureVector(this_patient_idx, this_feature_idx));
      else
        fprintf('%G]\n', obj.FeatureVector(this_patient_idx, this_feature_idx));
      end
    end
  end
end
