function test_null_crossval
% Function to test whether it's common for cross-validation of a null model
% (i.e., one that includes only a constant) to have an ROC curve with
% AUC << 0.5

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));
addpath(fullfile(qilsoftwareroot, 'image_features'));
close all;

rng('default'); % Reproducable results

%% Make variables
mcreps = 9;

n = 50;
Y = rand(n, 1) > 0.5;
X = zeros(length(Y), 0);

%% Run cross-validation
[MSE, predictedValues, ~, cvparray] = my_crossval(@crossval_fun_regress, X, Y, 'mcreps', mcreps);
predictedValues = repack_predicted_values(predictedValues, cvparray);

%% Plot output
% Plot boxplots of predicted value vs. true value
figure;
for kk = 1:length(predictedValues)
  subplot(3, 3, kk);
  boxplot(predictedValues{1}, Y);
  xlabel('True output class');
  ylabel('Model output value');
end
increase_font;

% Plot mean of training and test sets
figure;
for kk = 1:length(predictedValues)
  this_predicted_values = predictedValues{kk};
  this_cvp = cvparray{kk};
  num_test_sets = this_cvp.NumTestSets;
  test_set_mean = zeros(1, num_test_sets);
  train_set_mean = zeros(1, num_test_sets);
  for jj = 1:num_test_sets
    test_set_mean(jj) = mean(Y(this_cvp.test(jj)));
    train_set_mean(jj) = mean(Y(this_cvp.training(jj)));
  end
  
  subplot(3, 3, kk);
  plot([0 1], [0 1], 'k--', 'linewidth', 2);
  hold on;
  twiddle_std = 0.01;
  plot(test_set_mean + randn(size(test_set_mean))*twiddle_std, train_set_mean + randn(size(train_set_mean))*twiddle_std, 'o');
  xlabel('Test Mean');
  ylabel('Training Mean');
  axis([0 1 0 1]);
  increase_font;
end
1;
