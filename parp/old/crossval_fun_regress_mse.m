function y_hat = crossval_fun_regress_mse(xtrain, ytrain, xtest)
% Returns estimated results for crossval('mse', ...)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

b = [ones(size(ytrain)) xtrain]\ytrain;
y_hat = [ones(size(xtest, 1), 1) xtest]*b;
