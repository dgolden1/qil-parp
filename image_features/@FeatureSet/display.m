function display(obj)
% FeatureSet display function

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if isempty(obj)
  disp(obj);
  return;
end

if isempty(obj.FeatureCategoryName) && isempty(obj.FeatureCategoryPrettyName)
  feature_category_str = '';
else
  feature_category_str = sprintf(' %s (%s)', obj.FeatureCategoryPrettyName, obj.FeatureCategoryName);
end

fprintf('%dx%d feature vector of %d%s features for %d patients\n', ...
  size(obj.FeatureVector, 1), size(obj.FeatureVector, 2), size(obj.FeatureVector, 2), feature_category_str, size(obj.FeatureVector, 1));

if isempty(obj.Response)
  fprintf('No response defined\n');
else
  fprintf('Response: %s\n', obj.ResponseName);
end

if ~isempty(obj.Comment)
  fprintf('Comment: ''%s''\n', obj.Comment);
end

fprintf('Features:\n');
for pp = 1:length(obj.FeatureNames)
  if strcmp(obj.FeatureNames{pp}, obj.FeaturePrettyNames{pp})
    fprintf('%s\n', obj.FeatureNames{pp});
  else
    fprintf('%s (%s)\n', obj.FeaturePrettyNames{pp}, obj.FeatureNames{pp});
  end
end

patient_ids_cellstr = patient_id_tostr(obj.PatientIDs, true);
fprintf('Patient IDs: ');
for nn = 1:length(patient_ids_cellstr)
  this_patient_id = patient_ids_cellstr{nn};
  if nn < length(patient_ids_cellstr)
    fprintf('%s, ', this_patient_id);
  else
    fprintf('%s\n', this_patient_id);
  end
end

fprintf('\n');
