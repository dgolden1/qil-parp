function obj = CreateFromStruct(FeatureStruct, FeaturePrettyNames, FeatureCategoryName, FeatureCategoryPrettyName)
% Create a FeatureSet object from a struct

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~isstruct(FeatureStruct)
  error('feature_struct must be a struct');
end
if ~isfield(FeatureStruct, 'patient_id')
  error('feature_struct must have a patient_id field');
end

% Allow either numeric or string patient IDs
patient_id = {FeatureStruct.patient_id}.';
if all(cellfun(@isnumeric, patient_id))
  patient_id = cell2mat(patient_id);
end

fn = fieldnames(rmfield(FeatureStruct, 'patient_id'));

X = nan(length(FeatureStruct), length(fn));
X_names = cell(1, length(fn));
for kk = 1:length(fn)
  X(:,kk) = [FeatureStruct.(fn{kk})].';
  X_names{kk} = fn{kk};
end

obj = FeatureSet(X, patient_id, X_names, FeaturePrettyNames, FeatureCategoryName, FeatureCategoryPrettyName);
