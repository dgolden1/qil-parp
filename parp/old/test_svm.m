function test_svm
% Test how support vector machines work on models with interaction terms

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Set up response and predictors
rng('default');

x = rand(100, 3);
y = x(:,1) > 0.5 & x(:,2) > 0.3 & rand(100,1) > 0.1;

%% Regression
[inmodel, history] = sequentialfs(@crossval_fun_logistic_regress, x, y);
mse_regress = sum(cv_regress)/length(y);

%% Lasso
[b_lasso_full, fitinfo] = lasso(x, y, 'CV', 10);
b_lasso = b_lasso_full(:,fitinfo.Index1SE);
mse_lasso = fitinfo.MSE(fitinfo.Index1SE);

%% SVM

cv_svm = crossval(@crossval_fun_svm, x, y);
