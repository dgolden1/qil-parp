function test_roc
% Do some tests with ROC curves

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

close all;

rng('default');

X = randn(50, 4);
Y_bino = randn(50, 1) > 0;
Y(~Y_bino, 1) = {'true'};
Y(Y_bino, 1) = {'false'};
X_names = mat2cell(num2str((1:size(X, 2)).'), ones(size(X, 2), 1)).';
Y_name = 'blah';
b_verbose = true;
b_plot = true;

stat_analysis_run_lasso(X, repmat({''}, 1, size(X, 2)), Y, Y_name, 'num_categories', 2);
