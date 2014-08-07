function criterion = crossval_fun_logistic_regress(xtrain, ytrain, xtest, ytest)
% Returns performance criteria for sequential feature selection
% (sequentialfs) via logistic regression

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$


[b, dev, stats] = glmfit(xtrain, ytrain, 'binomial', 'link', 'logit');
yhat = glmval(b, xtest, 'logit');

criterion = sum(deviance(yhat, ytest));

% Number of wrong answers
% criterion = sum((yhat > 0.5) ~= ytest);
