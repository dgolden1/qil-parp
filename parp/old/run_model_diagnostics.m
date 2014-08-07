function run_model_diagnostics(b_stanford_only)
% My training error is low and prediction error is high. Run diagnostics to
% figure out whether this is due to high variance (overfitting) or high
% bias (underfitting)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Setup
t_net_start = now;

if ~exist('b_stanford_only', 'var') || isempty(b_stanford_only)
  b_stanford_only = false;
end

max_num_features = Inf;

num_iterations = 5;

load('lesion_parameters.mat', 'lesions');

%% Remove outliers
lesions = exclude_patients(lesions, b_stanford_only);

%% Set up input and output matrices
[x, x_names, patient_ids] = get_glcm_model_inputs(lesions);
si = get_spreadsheet_info(patient_ids);
y = [si.rcb_value].';

%% Get training and prediction error for subsets of data
numinputs_vec = 3:length(y);
% numinputs_vec = 3:6;

for jj = 1:num_iterations
  t_iter_start = now;
  
  random_index = randperm(length(y));
  for kk = 1:length(numinputs_vec)
    t_start = now;

    numinputs = numinputs_vec(kk);
    input_idx = random_index(1:numinputs);

    this_x = x(input_idx, :);
    this_y = y(input_idx);
    this_patient_ids = patient_ids(input_idx);

    % Determine training error
    [rms_error_train(kk,1), r_train(kk,1)] = model_training_error(this_x, x_names, this_y, this_patient_ids, ...
      'max_num_features', max_num_features, 'b_plot', false);

    % Determine prediction error
    [rms_error_pred(kk,1), r_pred(kk,1)] = model_prediction_error(this_x, x_names, this_y, this_patient_ids, ...
      'max_num_features', max_num_features, 'b_plot', false);

    fprintf('Got training and prediction errors for %d patients (%d of %d) in %s\n', ...
      numinputs, kk, length(numinputs_vec), time_elapsed(t_start, now));
  end
  
  rms_error_train_vec{jj} = rms_error_train(:);
  rms_error_pred_vec{jj} = rms_error_pred(:);
  
  fprintf('Completed iteration %d of %d in %s\n', jj, num_iterations, time_elapsed(t_iter_start, now));
end
%% Save output
output_filename = '~/temp/parp_model_diagnostics.mat';
save(output_filename);
fprintf('Saved %s\n', output_filename);

%% Plot results
figure;

% Plot range of training and prediction error
if num_iterations > 1
  patch([numinputs_vec, fliplr(numinputs_vec)], ...
    [min(cell2mat(rms_error_train_vec), [], 2); flipud(max(cell2mat(rms_error_train_vec), [], 2))], [0.5 0.5 1]);
  hold on;
  patch([numinputs_vec, fliplr(numinputs_vec)], ...
    [min(cell2mat(rms_error_pred_vec), [], 2); flipud(max(cell2mat(rms_error_pred_vec), [], 2))], [0.5 1 0.5]);
end

% Plot average training and prediction error
plot(numinputs_vec, [mean(cell2mat(rms_error_train_vec), 2), mean(cell2mat(rms_error_pred_vec), 2)], 'linewidth', 2);

grid on;
box on;
xlabel('Num inputs');
ylabel('RMS error (RCB)');
title(sprintf('%d iterations', num_iterations));
legend('Training', 'Prediction');

% Print ID added at each step
if num_iterations == 1
  xlim([0, length(y) + 1]);
  yl = ylim;
  ids_y_height = yl(1) + 0.8*(diff(yl));
  for kk = 1:length(random_index)
    text(kk, ids_y_height, sprintf('%d', patient_ids(random_index(kk))), 'horizontalalignment', 'center');
  end
end

increase_font;

fprintf('Computed diangostics for %d iterations in %s\n', num_iterations, time_elapsed(t_net_start, now));

1;
