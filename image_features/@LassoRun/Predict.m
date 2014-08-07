function obj = Predict(obj)
% Run lasso or lasso glm 

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
t_lasso_start = now;

X = obj.ThisFeatureSet.FeatureVector;
X_names = obj.ThisFeatureSet.FeaturePrettyNames;

% warning('Parallel disabled');
% options = statset('UseParallel', 'Never');
options = statset('UseParallel', 'Always');

%% Ensure validity of cv and mcreps
if size(X, 1) < obj.ncvfolds
  warning('Too few samples (%d) for %d-fold cross-validation; reverting to leave-one-out cross-validation', size(X, 1), obj.ncvfolds);
  obj.ncvfolds = size(X, 1);
  obj.mcreps = 1;
end

%% Run lasso
switch obj.Type
  case 'binomial'
    % Binomial lasso regression

    if iscellstr(obj.Y)
      Y_bino = strcmp(obj.Y, obj.YPositiveClassLabel);
    else
      Y_bino = (obj.Y == obj.YPositiveClassLabel);
    end

    lasso_type_str = 'lassoglm';
    [obj.b, obj.fitinfo] = my_lassoglm(X, Y_bino, 'binomial', 'cv', obj.ncvfolds, 'PredictorNames', X_names, 'MCReps', obj.mcreps, 'Alpha', obj.alpha, 'options', options);

    obj.ROC = GetROC(obj);
  case 'gaussian'
    % Continuous lasso regression

    lasso_type_str = 'lasso';
    [obj.b, obj.fitinfo] = lasso(X, obj.Y, 'cv', obj.ncvfolds, 'PredictorNames', X_names, 'MCReps', obj.mcreps, 'Alpha', obj.alpha, 'options', options);
  case 'cox'
    % Cox proportional hazards lasso regression
    obj = PredictCox(obj);
  otherwise
    error('Unexpected type: %s', obj.Type);
end

obj.ElapsedSeconds = (now - t_lasso_start)*86400;

1;
