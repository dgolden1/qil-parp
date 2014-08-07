function [rms_error, r] = model_training_error(x, x_names, y, patient_ids, varargin)
% Select features and run linear regression model to determine model
% and plot model training error

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
p = inputParser;
p.addParamValue('max_num_features', inf);
p.addParamValue('method', 'regress_sfs')
p.addParamValue('b_plot', true);
p.addParamValue('b_verbose', false);
p.parse(varargin{:});
max_num_features = p.Results.max_num_features;
method = p.Results.method;
b_plot = p.Results.b_plot;
b_verbose = p.Results.b_verbose;

%% Specify and run model
switch method
  case 'regress_sfs'
    [x_idx, b] = specify_model_regress(x, y, x_names, 'max_num_features', max_num_features, 'b_verbose', b_verbose);
    [y_hat, rms_error, r] = run_model_regress(x(:, x_idx), b, y);
  case 'lasso'
    if ~isinf(max_num_features)
      warning('max_num_features is not respected for lasso regression');
    end
    b = specify_model_lasso(x, y, x_names);
    [y_hat, rms_error, r] = run_model_regress(x, b, y);
  case 'mean'
    b = mean(y);
    [y_hat, rms_error, r] = run_model_regress(zeros(length(y), 0), b, y);
end

%% Plot output
if b_plot
  num_features = sum(b > 0) - 1; % Subtract one to exclude the constant
  plot_model_performance(y, y_hat, patient_ids, num_features, 'Training');
end

