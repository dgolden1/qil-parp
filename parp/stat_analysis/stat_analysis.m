function results_struct = stat_analysis(feature_set, Y, Y_name, varargin)
% Perform some general statistical analyses that should work for all types
% of quantitative features
% 
% results_struct = stat_analysis(feature_set, Y, Y_name, 'param', value, ...)
% 
% In general, response (Y) may be continuous or boolean, but not categorical
% feature_set is a FeatureSet object and may be continuous features, dummy
%  features which are 0 or 1 (corresponding to categories), or some
%  combination of the two
%
% PARAMETERS
% b_all: do all possible analyses for this format features/response
% b_ecdf: make empirical CDF for each category if X is categories (features
%  categorical only)
% b_ks_matrix: make a matrix of kolmogorov smirnov tests, testing whether
%  the CDF of the response is larger for any given feature when compared
%  with another (features categorical, response continuous)
% b_boxplots: make box plots with 95% confidence intervals for
%  each feature (one of features or response must be categorical, and the
%  other must be continuous)
% b_proportion_plots: make plot of binomial proportion of response for each
%  feature (features categorical, response categorical)
% b_ranksum: perform the Wilcoxon rank-sum test to determine whether there
%  is a significant difference in the values of each feature for two
%  categories of response (response boolean only)
% b_fishers_exact: make a matrix of Fisher's Exact tests, testing whether
%  the likelihood of outcomes is significantly different when two features
%  are compared (features categorical, response categorical)
% b_regression: generate multiple regression model to predict response
% b_lasso: generate lasso model to predict response

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
close all;

b_features_categorical = isequal(unique(feature_set.FeatureVector(:)), [0 1].');
b_response_categorical = iscell(Y) && all(cellfun(@ischar, Y));

results_struct = struct;

%% Parse input parameters
p = inputParser;
p.addParamValue('b_ecdf', false);
p.addParamValue('b_ks_matrix', false);
p.addParamValue('b_boxplots', false);
p.addParamValue('b_proportion_plots', false);
p.addParamValue('b_ranksum', false);
p.addParamValue('b_fishers_exact', false);
p.addParamValue('b_regression', false);
p.addParamValue('b_lasso', false);
p.addParamValue('b_all', []);
p.parse(varargin{:});

% Set b_all to true if not parameters given
b_all = isempty(varargin) || ~isempty(p.Results.b_all) && p.Results.b_all;

%% Empirical CDF
if p.Results.b_ecdf || (b_all && b_features_categorical && ~b_response_categorical)
  if ~xor(b_features_categorical, b_response_categorical)
    error('To plot ECDF, one of features or response must be categorical, but not both');
  end
  
  plot_ecdf(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name, b_features_categorical, b_response_categorical);
end

%% Kolmogorov-Smirnov Matrix
if p.Results.b_ks_matrix || (b_all && b_features_categorical && ~b_response_categorical)
  if ~b_features_categorical
    error('To run kstest, features must be categorical');
  end
  if b_response_categorical
    error('To run kstest, response must be continuous');
  end
  
  plot_ksmatrix(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name);
end

%% Box-whisker plots
if p.Results.b_boxplots || (b_all && xor(b_features_categorical, b_response_categorical))
  if ~xor(b_features_categorical, b_response_categorical)
    error('To plot box-whisker plots, one of features or response must be categorical, but not both');
  end
  
  plot_box_whisker(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name, b_features_categorical, b_response_categorical);
end

%% Proportion Plots
if p.Results.b_proportion_plots || (b_all && b_features_categorical && b_response_categorical)
  if ~(b_features_categorical && b_response_categorical)
    error('For proportion plots, both features and response must be categorical');
  end
  
  plot_proportions(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name);
end

%% Wilcoxon Rank Sum Test
if p.Results.b_ranksum || (b_all && ~b_features_categorical && b_response_categorical)
  if b_features_categorical
    error('To run ranksum, features must be continuous');
  end
  if ~b_response_categorical
    error('To run ranksum, response must be categorical');
  end
  
  run_ranksum(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name);
end

%% Fisher's Exact Test
if p.Results.b_fishers_exact || (b_all && b_features_categorical && b_response_categorical)
  if ~b_features_categorical
    error('To run Fisher''s exact test, features must be categorical');
  end
  if ~b_response_categorical
    error('To run Fisher''s exact test, response must be categorical');
  end
  
  run_fishers_exact(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name);
end

%% Regression
if p.Results.b_regression || b_all
  run_regression(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name, b_response_categorical);
end

%% Lasso
if p.Results.b_lasso || b_all
  if b_response_categorical
    num_categories = length(unique(Y));
  end
  results_struct.lasso = stat_analysis_run_lasso(feature_set.FeatureVector, feature_set.FeatureNames, Y, Y_name, 'num_categories', num_categories);
end


function plot_ecdf(X, X_names, Y, Y_name, b_features_categorical, b_response_categorical)
%% Function: plot empirical CDF

if b_features_categorical && ~b_response_categorical
  figure;
  hold on;
  colors = get(gca, 'colororder');
  for kk = 1:length(X_names)
    [ecdfs{kk}, ecdfs_x{kk}] = ecdf(Y(X(:,strcmp(X_names, X_names{kk})) ~= 0));
    stairs(ecdfs_x{kk}, ecdfs{kk}, 'linewidth', 2, 'color', colors(kk,:));
  end

  xlabel(Y_name);
  ylabel('Empirical CDF');
  legend(strrep(X_names, '_', ' '), 'location', 'southeast');
  box on;
  grid on
  increase_font;
elseif ~b_features_categorical && b_response_categorical
  % Make a empirical CDFsfor each feature representing feature
  % values for each response category
  
  output_dir = '/Users/dgolden/temp/feature_ecdfs';
  if ~exist(output_dir, 'dir')
    mkdir(output_dir);
  end
  
  Y_unique = unique(Y);
  Y_cat_true = Y_unique{1};
  Y_cat_false = Y_unique{2};

  figure;
  for kk = 1:length(X_names)
    t_start = now;

    clf;
    [ftrue, xtrue] = ecdf(X(strcmp(Y, Y_cat_true), kk));
    [ffalse, xfalse] = ecdf(X(~strcmp(Y, Y_cat_true), kk));
    
    % plot(xtrue, ftrue, 'b', xfalse, ffalse, 'r', 'linewidth', 2);
    stairs(xtrue, ftrue, 'b', 'linewidth', 2);
    hold on;
    stairs(xfalse, ffalse, 'r', 'linewidth', 2);
    grid on;
    
    xlabel(sprintf('%s (feat %d)', strrep(X_names{kk}, '_', '\_'), kk));
    ylabel('Empirical CDF');
    legend(Y_cat_true, Y_cat_false, 'Location', 'SouthEast');
    increase_font;

    output_filename = fullfile(output_dir, sprintf('feature_%03d', kk));
    print_trim_png(output_filename);
    fprintf('Wrote %s (%d of %d) in %s\n', output_filename, kk, length(X_names), time_elapsed(t_start, now));
  end
end
  
% print_trim_png('~/temp/man_cat_ecdf');

function plot_ksmatrix(X, X_names, Y, Y_name)
%% Function: make Kolmogorov-Smirnov matrix

b_two_sided = true; % One sided or two-sided kstest

category = dummy_to_label(X, X_names);
categories = X_names;

h_kstest = nan(length(categories)); % True if the null hypothesis is rejected at 5% significane
p_kstest = nan(length(categories)); % p-value

if b_two_sided
  % Alternate hypothesis: Y_1 ~= Y_2
  % Null hypothesis: Y_1 == Y_2
  kstest_type = 'unqeual';
  plot_title = sprintf('Red if null hypothesis (%s_{left} ~= %s_{bottom}) is rejected @ 5%%', Y_name, Y_name);
else
  % Alternate hypothesis: Y_1 > Y_2
  % Null hypothesis: Y_1 <= Y_2
  kstest_type = 'larger';
  plot_title = sprintf('Red if null hypothesis (%s_{left} <= %s_{bottom}) is rejected @ 5%%', Y_name, Y_name);
end

for jj = 1:length(categories)
  for kk = 1:length(categories)
    if b_two_sided && kk >= jj
      continue;
    end
    
    category_1 = categories{jj};
    category_2 = categories{kk};
    
    Y_1 = Y(strcmp(category, category_1));
    Y_1 = Y_1(isfinite(Y_1));
    Y_2 = Y(strcmp(category, category_2));
    Y_2 = Y_2(isfinite(Y_2));
    
    idx = sub2ind(size(h_kstest), jj, kk);
    
    % According to the Matlab documentation, the kstest is not valid if
    % this is not true
    if length(Y_1)*length(Y_2)/(length(Y_1) + length(Y_2)) >= 4
      [h_kstest(idx), p_kstest(idx)] = kstest2(Y_1, Y_2, 0.05, kstest_type);
    end
  end
end

figure;
[new_image_data, new_color_map, new_cax] = colormap_white_bg(h_kstest, jet, [0 1]);
imagesc(new_image_data);
colormap(new_color_map);
caxis(new_cax);
for kk = 1:length(categories)
  ylabels{kk} = sprintf('%s %d', categories{kk}, kk);
end
set(gca, 'ytick', 1:length(categories), 'yticklabel', ylabels, 'xtick', 1:length(categories));
title(plot_title);
increase_font;

% print_trim_png('~/temp/man_cat_kstest_matrix');

function run_fishers_exact(X, X_names, Y, Y_name)
%% Function: Make Fisher's Exact Test Matrix

Y_unique_vals = unique(Y);
if length(Y_unique_vals) ~= 2
  error('Y should have exactly two unique values');
end

b_two_sided = true; % One sided or two-sided test

category = dummy_to_label(X, X_names);
categories = X_names;

Y_dummy = label_to_dummy(Y);

h_fetest = nan(length(categories)); % True if the null hypothesis is rejected at 5% significane
p_fetest = nan(length(categories)); % p-value

if b_two_sided
  % Alternate hypothesis: Y_1 ~= Y_2
  % Null hypothesis: Y_1 == Y_2
  fetest_type = 'b';
  plot_title = sprintf('Red if null hypothesis (%s_{left} == %s_{bottom}) is rejected @ 5%%', Y_name, Y_name);
else
  % Alternate hypothesis: Y_1 > Y_2
  % Null hypothesis: Y_1 <= Y_2
  fetest_type = 'r';
  plot_title = sprintf('Red if null hypothesis (%s_{left} <= %s_{bottom}) is rejected @ 5%%', Y_name, Y_name);
end

for jj = 1:length(categories)
  for kk = 1:length(categories)
    if b_two_sided && kk >= jj
      continue;
    end
    
    category_1 = categories{jj};
    category_2 = categories{kk};
    
    % Only the first column of Y_dummy is used because the second column is
    % redundant
    idx_cat_1 = strcmp(category, category_1);
    idx_cat_2 = strcmp(category, category_2);
    Y_1 = Y_dummy(idx_cat_1, 1);
    Y_2 = Y_dummy(idx_cat_2, 1);
    
    X_combined = [zeros(sum(idx_cat_1), 1); ones(sum(idx_cat_2), 1)];
    Y_combined = [Y_1; Y_2];
    
    idx = sub2ind(size(h_fetest), jj, kk);
    
    p_fetest(idx) = fexact(X_combined, Y_combined, 'tail', fetest_type);
    h_fetest(idx) = p_fetest(idx) <= 0.05;
  end
end

figure;
[new_image_data, new_color_map, new_cax] = colormap_white_bg(h_fetest, jet, [0 1]);
imagesc(new_image_data);
colormap(new_color_map);
caxis(new_cax);
for kk = 1:length(categories)
  ylabels{kk} = sprintf('%s %d', categories{kk}, kk);
end
set(gca, 'ytick', 1:length(categories), 'yticklabel', ylabels, 'xtick', 1:length(categories));
title(plot_title);
increase_font;

function run_ranksum(X, X_names, Y, Y_name)
%% Function: run ranksum test to get p-values for each feature

Y_unique_vals = unique(Y);
if length(Y_unique_vals) ~= 2
  error('Y should have exactly two unique values');
end

p = zeros(1, length(X_names));
for kk = 1:length(X_names)
  % Two-sided p value is computed as
  % p = 2*(1 - normcdf(abs(stats.zval)))
  % Which is the area under outside of normal curve when cut on both sides
  % at z = stats.zval
  % One-sided p value is computed as
  % p = 1 - normcdf(abs(stats.zval))
  % Which is area under outside of normal curve when cut on only one side
  % 
  % However, I think I need to use the two-sided test because I don't know
  % a priori which category will have higher values of the feature
  
  [p(kk), ~, stats] = ranksum(X(strcmp(Y, Y_unique_vals{1}), kk), X(strcmp(Y, Y_unique_vals{2}), kk));
end

% Print significant p-values
feature_num = 1:length(X_names);
[p_sort, idx_p] = sort(p);
X_names_p_sort = X_names(idx_p);
feature_num_p_sort = feature_num(idx_p);
for kk = 1:length(p_sort)
  if p_sort(kk) <= 0.05
    fprintf('ranksum %s vs %s: %s (feature %d) p=%0.5G\n', Y_unique_vals{1}, Y_unique_vals{2}, X_names_p_sort{kk}, feature_num_p_sort(kk), p_sort(kk));
  end
end

if ~any(p_sort(kk) <= 0.05)
  fprintf('No significant features via ranksum test\n');
end

function plot_box_whisker(X, X_names, Y, Y_name, b_features_categorical, b_response_categorical)
%% Function: plot box-whisker plots

% Two scenarios: comparing continuous feature values for different
% categories of response, or comparing continuous response values for
% different feature categories

output_dir = '/Users/dgolden/temp/feature_boxplots';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

if b_features_categorical && ~b_response_categorical
  % Make one box-whisker plot for each feature category and plot them
  % together
  
  labels = dummy_to_label(X, X_names);
  
%   % Don't bother plotting against the constant
%   if strcmp(labels{1}, 'constant')
%     labels = labels(:,2:end);
%   end
  
  figure;
  figure_grow(gcf, 2, 1);
  for kk = 1:size(labels, 2)
    t_start = now;

    clf;
    boxplot(Y, strrep(labels(:,kk), ' ', sprintf('\n')), 'notch', 'on');
    ylabel(Y_name);
    increase_font;
    
    output_filename = fullfile(output_dir, sprintf('feature_%03d.png', kk));
    print_trim_png(output_filename);
    fprintf('Wrote %s (%d of %d) in %s\n', output_filename, kk, size(labels, 2), time_elapsed(t_start, now));
  end
else
  % Make a pair of box-whisker plots for each feature representing feature
  % values for each response category
  
  figure;

  for kk = 1:length(X_names)
    t_start = now;

    clf;
    boxplot(X(:,kk), Y, 'notch', 'on');
    title(sprintf('%s (feat %d)', strrep(X_names{kk}, '_', '\_'), kk));
    increase_font;

    output_filename = fullfile(output_dir, sprintf('feature_%03d', kk));
    print_trim_png(output_filename);
    fprintf('Wrote %s (%d of %d) in %s\n', output_filename, kk, length(X_names), time_elapsed(t_start, now));
  end  
end

function plot_proportions(X, X_names, Y, Y_name)
%% Function: plot binomial proportions, with 95% confidence intervals

Y_unique_vals = unique(Y);
if length(Y_unique_vals) ~= 2
  error('Y should have exactly two unique values');
end

% Get rid of 'constant' column if one exists
if all(strcmp(X_names(1), 'constant'))
  X_names = X_names(2:end);
  X = X(:, 2:end);
end

labels = dummy_to_label(X, X_names);

if size(labels, 2) > 1
  error('Only one categorical variable supported');
end

frac_cat1 = nan(length(X_names), 1);
for kk = 1:length(X_names)
  this_Y = Y(strcmp(labels, X_names{kk}));
  num_cat1(kk) = sum(strcmp(this_Y, Y_unique_vals{1}));
  num_cat2(kk) = sum(strcmp(this_Y, Y_unique_vals{2}));
  num_total(kk) = num_cat1(kk) + num_cat2(kk);
  frac_cat1(kk) = num_cat1(kk)/num_total(kk);

  [ac_mean(kk), ac_pm(kk)] = agresti_coull(num_total(kk), num_cat1(kk));
end

% Get agresti coull error bars

figure;
b = bar(1:length(X_names), frac_cat1);
set(b, 'facecolor', [1 1 1]*0.5);
hold on
errorbar(1:length(X_names), ac_mean, ac_pm, 'k', 'linestyle', 'none');
set(gca, 'xticklabel', X_names);
ylabel(sprintf('proportion %s', Y_unique_vals{1}));
title('Error bars are 95% confidence');
yl = ylim;
ylim([0 min(1, yl(2))]);
figure_grow(gcf, 2, 1);
increase_font;

% print_trim_png('~/temp/man_cat_pcr_prop');

function run_regression(X, X_names, Y, Y_name, b_response_categorical)
%% Function: Create regression model with sequential feature selection

if b_response_categorical
  Y_unique_vals = unique(Y);
  if length(Y_unique_vals) ~= 2
    error('Y should have exactly two unique values');
  end

  Y = strcmp(Y, Y_unique_vals{1}); % Convert Y to boolean
  
  sequential_fs_fun = @crossval_fun_logistic_regress;
else
  sequential_fs_fun = @crossval_fun_regress;
end

opts = statset('display', 'iter');

s(1) = warning('off', 'MATLAB:rankDeficientMatrix');
s(end+1) = warning('off', 'stats:glmfit:IterationLimit');
s(end+1) = warning('off', 'stats:glmfit:IllConditioned');
[inmodel, history] = my_sequentialfs(sequential_fs_fun, X, Y, 'options', opts);

for kk = 1:length(s)
  warning(s(kk).state, s(kk).identifier);
end

figure;
errorbar(1:length(history.Crit), history.Crit, history.CritSE, 'k', 'linestyle', 'none');
hold on;
plot(1:length(history.Crit), history.Crit, 'r.', 'markersize', 8);
grid on;
xlabel('Num features');

if b_response_categorical
  ylabel('Fraction mis-classification')
else
  ylabel('MSE');
end
increase_font;
