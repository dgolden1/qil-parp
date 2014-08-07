function crit = crossval_fun_svm(xtrain, ytrain, xtest, ytest)
% Function for cross validation of SVM
% Binary classification only!

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

svmstruct = svmtrain(xtrain, ytrain);
yhat = svmclassify(svmstruct, xtest);

% crit = sum(yhat ~= ytest); % Sum of classification errors

% Sum of percent of classification errors for each category, weighted by
% number of test samples, and normalized by fraction of each category
% represented
% crit = (sum(ytest & ~yhat)/sum(ytest) + sum(~ytest & yhat)/sum(~ytest))*length(ytest);

% F-measure: harmonic mean of precision and recall
precision = sum(yhat & ytest)/sum(yhat); % Fraction of identified positives that are correct
recall = sum(yhat & ytest)/sum(ytest); % Fraction of actual positives that are identified
crit = fmeasure(precision, recall)*length(ytest);

1;


function f = fmeasure(precision, recall)
% Calculate f-measure, which is the harmonic mean of the precision and
% recall
% See http://en.wikipedia.org/wiki/Precision_and_recall#F-measure

f = 2*precision*recall/(precision + recall);
