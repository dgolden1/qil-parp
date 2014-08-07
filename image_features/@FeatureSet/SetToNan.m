function feature_set_nans = SetToNan(obj)
% Set all values of feature set to NaN

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

feature_set_nans = obj;
feature_set_nans.FeatureVector(:) = nan;
