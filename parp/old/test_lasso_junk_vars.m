% function test_lasso
% A simple test program to see how lasso works with junk variables

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id$

close all;
clear;

% rng('default'); % Give reproducable results

addpath(fullfile(qilsoftwareroot, 'parp', 'stat_analysis'));

output_dir = '~/temp/test_lasso';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% Lasso
n = 50;
n_real_features = 5;
n_junk_features_vec = unique(round(logspace(0, 4, 100)));
mcreps = 10;
noise_std = 1;
opts = statset('UseParallel', 'Always');
if matlabpool('size') == 0
  matlabpool('open');
end

h_fig(1) = figure;
h_fig(2) = figure;

for kk = 1:length(n_junk_features_vec)
  n_junk_features = n_junk_features_vec(kk);
  
  idx_real_features = false(1, n_real_features + n_junk_features);
  idx_real_features(1:n_real_features) = true;
  
  X = randn(n, n_real_features + n_junk_features);
  Y = sum(X(:, idx_real_features), 2) + randn(n, 1)*noise_std;
  % Y = randn(n, 1);
  Y_name = '';
  b_response_categorical = false;
  for jj = 1:size(X, 2)
    X_names{jj} = sprintf('X%04d', jj);
  end
  
  fprintf('Run %d of %d with %d real features and %d junk features\n', kk, length(n_junk_features_vec), n_real_features, n_junk_features);
  
  lasso_output = stat_analysis_run_lasso(X, X_names, Y, Y_name, 'num_categories', 0, 'h_fig', h_fig);
  b = lasso_output.b;
  fitinfo = lasso_output.fitinfo;
  sfigure(1);
  print_trim_png(fullfile(output_dir, sprintf('lasso_cv_true_%03d_junk_%04d', n_real_features, n_junk_features)));
  sfigure(2);
  print_trim_png(fullfile(output_dir, sprintf('lasso_lambda_true_%03d_junk_%04d', n_real_features, n_junk_features)));

  chosen_b = b(:, fitinfo.Index1SE);
  precision(kk) = sum((chosen_b ~= 0) & idx_real_features.')/sum(chosen_b ~= 0);
  recall(kk) = sum(chosen_b ~= 0 & idx_real_features.')/sum(idx_real_features);
end

figure;
semilogx(n_junk_features_vec, precision, n_junk_features_vec, recall, 'linewidth', 2);
grid on;
xlabel('Num junk features');
legend('Precision', 'Recall');
title(sprintf('n = %d, n good features = %d, noise std = %0.1f', n, n_real_features, noise_std));
increase_font;
print_trim_png(fullfile(output_dir, 'lasso_precision_recall.jpg'));
