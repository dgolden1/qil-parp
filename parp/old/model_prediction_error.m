function [rms_error, r] = model_prediction_error(x, x_names, y, patient_ids, varargin)
% Select features and run linear regression model to determine model
% prediction error
% 
% Performs feature selection with one patient left out, and tests resulting
% model on left out patient

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

if strcmp(method, 'lasso') && ~isinf(max_num_features)
  warning('max_num_features is not respected for lasso regression');
end

%% Loop over patients
y_hat_pred = nan(size(y)); % Predicted RCB
for kk = 1:length(y)
  t_pred_err_start = now;
  
  modeled_patient_idx = [1:(kk-1) (kk+1):length(y)];
  leftout_patient_idx = kk;

  switch method
    case 'regress_sfs'
      % Specify model for all patients but the held out one
      [x_idx, this_b] = specify_model_regress(x(modeled_patient_idx,:), y(modeled_patient_idx), ...
        x_names, 'max_num_features', max_num_features);

      % Run the model on the held out patient
      y_hat_pred(kk) = run_model_regress(x(leftout_patient_idx, x_idx), this_b);
    case 'lasso'
      % Specify model for all patients but the held out one
      this_b = specify_model_lasso(x(modeled_patient_idx,:), y(modeled_patient_idx), x_names);

      % Run the model on the held out patient
      y_hat_pred(kk) = run_model_regress(x(leftout_patient_idx, :), this_b);
    case 'mean'
      this_b = mean(y(modeled_patient_idx));
      y_hat_pred(kk) = run_model_regress(zeros(1, 0), this_b);
  end
  
  if b_verbose
    this_num_features = sum(this_b > 0) - 1; % Subtract one to exclude the constant
    fprintf('Got prediction error for patient %d (%d of %d, %d features for %d patients) in %s\n', ...
      patient_ids(kk), kk, length(patient_ids), this_num_features, length(modeled_patient_idx), ...
      time_elapsed(t_pred_err_start, now));
  end
end

rms_error = sqrt(mean((y - y_hat_pred).^2));
r = corr(y, y_hat_pred);

%% Plot output
if b_plot
  num_features = [];
  plot_model_performance(y, y_hat_pred, patient_ids, num_features, 'Prediction');
end

