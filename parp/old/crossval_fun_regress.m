function [criterion, yhat] = crossval_fun_regress(xtrain, ytrain, xtest, ytest)
% Returns performance criteria for sequential feature selection
% (sequentialfs) via least squares regression

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

b = [ones(size(ytrain)) xtrain]\ytrain;
yhat = [ones(size(ytest)) xtest]*b;
criterion = sum((ytest - yhat).^2);

1;
