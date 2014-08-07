function obj = RemoveInvalidFeatures(obj, b_verbose)
% Remove features with NaN values

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end

idx_nan = any(~isfinite(obj.FeatureVector), 1);
features_to_remove = obj.FeatureNames(idx_nan);
obj = RemoveFeatures(obj, features_to_remove, b_verbose, 'with non-finite patients');
