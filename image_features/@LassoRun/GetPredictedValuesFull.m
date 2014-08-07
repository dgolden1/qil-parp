function [predicted_values, dev, cv_pred_se, cv_pred_mean, cv_dev] = GetPredictedValuesFull(obj)
% Get predicted values for the full lasso model that was run without cross-validation
% [predicted_values, dev, se, se_mean] = GetPredictedValuesFull(obj)
% 
% OUTPUTS
% NOTE: all outputs use the 1SE value of lambda
% predicted_values: the values predicted for each patient from the full,
%  non-cross-validated lasso model
% dev: the deviance of the full, non-cross-validated model for each patient
% cv_pred_se: the standard error of the cross-validated predicted values for each
%  patient over all Monte Carlo repetitions
% cv_pred_mean: the mean of the cross-validated predicted values for each patient over
%  all Monte Carlo repetitions

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Convert response to logical
Y = obj.Y;
if iscellstr(Y)
  % Convert Y from cellstr to logical
  Y_unique = unique(Y);
  assert(length(Y_unique) == 2);
  Y = strcmp(Y, obj.YPositiveClassLabel);
end

%% Determine predicted output for full model
X = obj.ThisFeatureSet.FeatureVector;
b = obj.b(:, obj.fitinfo.Index1SE);
intercept = obj.fitinfo.Intercept(obj.fitinfo.Index1SE);
Y_fit = intercept + X*b;
predicted_values = exp(Y_fit)./(1 + exp(Y_fit)); % logit function

%% Get deviance and error bars
dev = deviance(predicted_values, Y);

% One row for every patient, one column for each MC repetition
pred_values_cv = cell2mat(obj.fitinfo.predictedValues(:, obj.fitinfo.Index1SE).');
cv_pred_se = std(pred_values_cv, [], 2);
cv_pred_mean = mean(pred_values_cv, 2);

cv_dev = zeros(size(pred_values_cv));
for kk = 1:length(Y)
  cv_dev(kk,:) = deviance(pred_values_cv(kk,:), Y(kk));
end
1;
