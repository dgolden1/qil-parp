function obj = SortFeatures(obj)
% Sort feature names

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

[~, idx_sort] = sort(obj.FeatureNames);
obj.FeatureNames = obj.FeatureNames(idx_sort);
obj.FeaturePrettyNames = obj.FeaturePrettyNames(idx_sort);
obj.FeatureVector = obj.FeatureVector(:,idx_sort);
