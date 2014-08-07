function b_features_categorical = BFeaturesCategorical(obj)
% Output is true for categorical features (features with values equal only to 0 or 1)

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

b_features_categorical = false(1, size(obj.FeatureVector, 2));
for kk = 1:size(obj.FeatureVector, 2)
  unique_vals = unique(obj.FeatureVector(:,kk));
  
  b_features_categorical(kk) = isequal(unique_vals, [0 1].');
end
