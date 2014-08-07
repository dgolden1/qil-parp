function values = GetValuesByFeature(obj, feature_names)
% Get some values from the FeatureVector by feature name

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

if ~exist('feature_names', 'var') || isempty(feature_names)
  idx_features = 1:length(obj.FeatureNames);
else
  if ischar(feature_names)
    feature_names = {feature_names};
  end
  
  idx_features = find(ismember(obj.FeatureNames, feature_names) | ismember(obj.FeaturePrettyNames, feature_names));
  
  if isempty(idx_features)
    invalid_features = setdiff(feature_names, [obj.FeatureNames, obj.FeaturePrettyNames]);
    error('Given features (%s) not found in FeatureSet', make_comma_separated_list(invalid_features));
  end
end

values = obj.FeatureVector(:, idx_features);
