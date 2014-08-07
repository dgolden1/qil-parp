% function test_lasso
% A simple test program to see how lasso works with junk variables

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id$

%% Setup
close all;
clear;

%rng('default'); % Give reproducable results

%% Lasso params
n = 20;
n_real_features = 3;
n_junk_features = 5 - n_real_features;
mcreps = 10;
noise_std = 0.1;
alpha = 1;
opts = statset('UseParallel', 'Always');
% opts = statset('UseParallel', 'Never');
if matlabpool('size') == 0
  matlabpool('open');
end


idx_real_features = false(1, n_real_features + n_junk_features);
idx_real_features(1:n_real_features) = true;

X = randn(n, n_real_features + n_junk_features);

if n_real_features == 0
  Y = randn(n, 1) > 0;
else
  Y = sum(X(:, idx_real_features), 2) + randn(n, 1)*noise_std > 0;
end

for jj = 1:size(X, 2)
  X_names{jj} = sprintf('X%04d', jj);
end
Y_name = '';

fs = FeatureSet(X, 1:length(X), X_names, []);

lasso_type_str = 'lassoglm';

%% Run lasso
lr = LassoRun(fs, Y, 'response', true, 'b_save_plots', false);

figure;
boxplot(lr.fitinfo.predictedValues{1, lr.fitinfo.Index1SE}, Y);
xlabel('True output class');
ylabel('Model output value');
increase_font;

1;
