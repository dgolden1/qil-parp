function select_model_features(b_stanford_only, max_num_features)
% Run sequential feature selection to choose regression model features

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if ~exist('b_stanford_only', 'var') || isempty(b_stanford_only)
  b_stanford_only = false;
end
if ~exist('max_num_features', 'var') || isempty(max_num_features)
  max_num_features = Inf;
end

% method = 'regress_sfs'; % Regression with sequential feature selection
method = 'lasso'; % Lasso regression
% method = 'mean'; % Just use mean RCB ('naive' method)

load('lesion_parameters.mat', 'lesions');

%% Remove outliers
lesions = exclude_patients(lesions, b_stanford_only);

%% Set up input and output matrices
[x, x_names, y, patient_ids] = get_glcm_model_inputs(lesions);

%% Turn into principal components
% [~, x] = princomp(zscore(x));
% for kk = 1:length(x_names)
%   x_names{kk} = sprintf('PC %d', kk);
% end

%% Determine training error
[rms_error_training, r_train] = model_training_error(x, x_names, y, patient_ids, ...
  'method', method, 'max_num_features', max_num_features, 'b_plot', true);

%% Determine prediction error
[rms_error_pred, r_pred] = model_prediction_error(x, x_names, y, patient_ids, ...
  'method', method, 'max_num_features', max_num_features, 'b_plot', true, 'b_verbose', true);

1;
