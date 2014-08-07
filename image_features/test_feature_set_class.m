function test_feature_set_class
% Run some tests on the FeatureSet class to ensure that it works

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: test_feature_set_class.m 124 2012-12-11 23:43:40Z dgolden $

fs1 = FeatureSet(ones(3), {'a', 'b', 'c'}, {'x', 'y', 'z'}, [], 'feature1');
fs2 = FeatureSet(zeros(3), {'b', 'c', 'd'}, {'x', 'y', 'z'}, [], 'feature2');

fs_combined = [fs1 fs2];

fs1, fs2, fs_combined

1;
