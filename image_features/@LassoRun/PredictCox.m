function obj = PredictCox(obj)
% Run predictive model with Cox proportional hazards regression via R
% 
% NOTE
% The following R packages must be installed
% glmnet
% cvTools
% R.matlab
% 
% Install packages in R via install.packages('package.name')

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id$

%% Setup
% Perform cross validation in R or Matlab
cv_method = 'R';
% cv_method = 'matlab';

%% Extract variables
x = obj.ThisFeatureSet.FeatureVector;
y = [obj.Y.time].';
b_censored = strcmp({obj.Y.event}, 'Censored').';
alpha = obj.alpha;
mcreps = obj.mcreps;

% Throw an error if there are invalid (infinite or NaN) values for any features
% We could remove the offending patients here, but then it's not clear to the caller how
% many patients were involved
invalid_feature_idx = any(~isfinite(x), 1);
if any(invalid_feature_idx)
  error('Some patients have non-finite values for feature(s): %s', make_comma_separated_list(obj.ThisFeatureSet.FeaturePrettyNames(invalid_feature_idx)));
end

%% Run outer cross-validation loop
switch cv_method
  case 'R'
    [pval, linear_predictors, sextiles, logrank_p, b, fitinfo] = outer_cv_loop_R(obj, x, y, b_censored, obj.alpha, obj.ncvfolds, obj.mcreps);
  case 'matlab'
    error('Not implemented');
end

obj.b = b;
obj.fitinfo = fitinfo;
obj.fitinfo.pval = pval;
obj.fitinfo.linear_predictors = linear_predictors;
obj.fitinfo.sextiles = sextiles;
obj.fitinfo.logrank_p = logrank_p;


1;

function [pval, linear_predictors, sextiles, logrank_p, b, fitinfo] = outer_cv_loop_R(obj, x, y, b_censored, alpha, ncvfolds, mcreps)
%% Function: outer cross-validation loop in R

if ncvfolds == length(y)
  % Leave-one-out cross-validation
  mcreps = 1;
end

r_script_filename = fullfile(expand_tilde(danmatlabroot), 'image_features', 'cox_lasso_r', 'cox_lasso_train_test_cv_matlab_interface.R');

% Run cross-validation
pval = cell(1, mcreps);
linear_predictors = cell(1, mcreps);
for kk = 1:mcreps
  t_start = now;

  if kk == 1
    b_net_model = true;
  else
    b_net_model = false;
  end
  
  r_out = run_r_script(r_script_filename, 'b_echo', true, 'args', {'x', 'y', 'b_censored', 'alpha', 'ncvfolds', 'b_net_model'});

  fprintf('Ran R Cox Lasso outer cross-validation iteration %d of %d in %s\n', kk, mcreps, time_elapsed(t_start, now));

  pval{kk} = r_out.cox_coef(strcmp(r_out.cox_coef_names, 'Pr(>|z|)'));
  linear_predictors{kk} = r_out.linear_predictors;
  sextiles{kk} = r_out.sextiles;
  logrank_p{kk} = struct('p_median', r_out.log_rank_strata_median_p, 'p_thirds', r_out.log_rank_strata_third_p);
  
  if kk == 1
    b = r_out.net_model_output.beta;
    fitinfo = extract_fitinfo(obj, r_out.net_model_output, alpha);
  end
end

1;


function outer_cv_loop_matlab(x, y, b_censored, alpha, ncvfolds, mcreps)
%% Function: outer cross-validation loop in Matlab

% Run cross-validation
nfolds = 10;
cvp = cvpartition(length(y), 'kfold', nfolds);
linear_predictors = nan(size(y));
for kk = 1:nfolds
  idx_train = training(cvp, kk);
  idx_test = test(cvp, kk);
  
  x_train = x(idx_train, :);
  y_train = y(idx_train);
  b_censored_train = b_censored(idx_train);
  x_test = x(idx_test, :);
  y_test = y(idx_test);
  b_censored_test = b_censored(idx_test);
  
  % Get linear predictors; they may be zero if the null model was chosen during the
  % lambda selection procedure
  linear_predictors(idx_test) = crossval_fun_r_cox_glmnet(x_train, y_train, b_censored_train, x_test, y_test, b_censored_test, alpha);
end


function vals = crossval_fun_r_cox_glmnet(x_train, y_train, b_censored_train, x_test, y_test, b_censored_test, alpha)
%% Function: cross-validation function for evaluating Cox PH glmnet model

t_start = now;
r_script_filename = fullfile(danmatlabroot, 'image_features', 'cox_lasso_r', 'cox_lasso_train_test_matlab_interface.R');
r_out = run_r_script(r_script_filename, 'x_train', 'y_train', 'b_censored_train', 'x_test', 'y_test', 'b_censored_test', 'alpha');

dt = time_elapsed(t_start, now);

% Linear predictors are the unitless values that are returned from predict.cv.glmnet for
% the cox model that should themselves be predictive of survival. These are NOT a
% measure of error, but will be used after the cross-validation is complete to compute
% the net error, in the form of a p-value in another standard Cox model
vals = r_out.linear_predictors;

1;

function fitinfo = run_r_cox_glmnet(x, event_times, b_censored, alpha, b_save_plots)
%% Function: run R Cox PH cv.glmnet code

%% Run R script
t_start = now;
r_script_filename = fullfile(danmatlabroot, 'image_features', 'cox_lasso_r', 'cox_lasso_matlab_interface.R');
r_out = run_r_script(r_script_filename, 'x', 'event_times', 'b_censored', 'alpha', 'b_save_plots');
fprintf('Ran R script %s in %s\n', r_script_filename, time_elapsed(t_start, now));

%% Save coefficients
obj.b = r_out.beta;
fitinfo = extract_fitinfo(r_out);


function fitinfo = extract_fitinfo(obj, r_out, alpha)
%% Function: extract info from R Lasso fit and put in same fitinfo structure used by Matlab

fitinfo = struct('Lambda', r_out.lambda.', 'Alpha', alpha, 'DF', double(r_out.nzero).', 'Deviance', r_out.cvm.', ...
                 'IndexMinDeviance', interp1(r_out.lambda, 1:length(r_out.lambda), r_out.lambda_min, 'nearest'), ...
                 'Index1SE', interp1(r_out.lambda, 1:length(r_out.lambda), r_out.lambda_1se, 'nearest'), ...
                 'LambdaMinDeviance', r_out.lambda_min, 'Lambda1SE', r_out.lambda_1se, 'SE', r_out.cvsd.', ...
                 'Intercept', zeros(size(r_out.lambda)).');

% Since FeaturePrettyNames is a cell array, this field has to be set separately, or else
% fitinfo will have the same dimension as FeaturePrettyNames
fitinfo.PredictorNames = obj.ThisFeatureSet.FeaturePrettyNames;

1;
