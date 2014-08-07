function obj = RemoveFeatures(obj, features_to_remove, b_verbose, message_str)
% Remove features

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = false;
end
if ~exist('message_str', 'var')
  message_str = '';
end
if ~isempty(message_str)
  message_str = [' ' message_str];
end

idx_remove = ismember(obj.FeatureNames, features_to_remove) | ismember(obj.FeaturePrettyNames, features_to_remove);

removed_feature_names = obj.FeatureNames(idx_remove);
obj.FeatureVector(:, idx_remove) = [];
obj.FeatureNames(idx_remove) = [];
obj.FeaturePrettyNames(idx_remove) = [];

if any(idx_remove) && b_verbose
  fprintf('Removed features%s:\n', message_str);
  for kk = 1:length(removed_feature_names)
    fprintf('%s\n', removed_feature_names{kk});
  end
end
end

