function test_lasso_run
% Function to test the LassoRun class

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

X = randn(20, 3);
Y = X(:,1) + randn(20, 1)*0.1;
patient_ids = cellfun(@(x) num2str(x, '%03d'), num2cell(1:size(X, 1)).', 'uniformoutput', false);
feature_names = cellfun(@(x) sprintf('Feature %02d', x), num2cell(1:size(X, 2)), 'uniformoutput', false);
feature_category_name = 'test';

FS = FeatureSet(X, patient_ids, feature_names, [], feature_category_name);
FS.Response = Y;
FS.ResponseName = 'response';
LR = LassoRun(FS, [], [], 'mcreps', 4);

1;
