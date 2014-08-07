function obj = RemoveConstantFeatures(obj, b_verbose)
% Remove features that are constant across all patients (have no variance)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end

idx_constant = nanstd(obj.FeatureVector) == 0 | all(isnan(obj.FeatureVector));
features_to_remove = obj.FeatureNames(idx_constant);
obj = RemoveFeatures(obj, features_to_remove, b_verbose, 'with no variance');
