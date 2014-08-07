function output_stats = stat_analysis_run_lasso(X, X_names, Y, Y_name, varargin)
% Run lasso or lasso glm with some nice plots and stuff
% output_stats = stat_analysis_run_lasso(X, X_names, Y, Y_name, num_categories)
% 
% INPUTS
% X: NxP matrix of N samples of P features
% X_names: length P cell array of the name of each feature
% Y: length N array of either (1) a continuous numerical values or (2)
%  strings representing TWO AND ONLY TWO possible categorical outputs
% Y_name: the name of the categorical output (for plots), e.g., 'response'
% 
% PARAMETERS
% mcreps: number of monte-carlo repetitions of the lasso procedure
% (default: 10)
% alpha: value of alpha for lasso (1=lasso, 0=ridge, everything else is
%  elastic net)
% num_categories: number of categories if the response is categorical, 0
%  if response is continuous (default: automatically determined based on
%  class of Y)
% b_verbose: true to print a bunch of output (default: true)
% b_plot: true to make plots of output (default: true)
% h_fig: a vector of 2 (for continuous Y) or 3 (for categorical Y) figure
%  handles on which to plot output. If not given, new figures will be
%  created.
% 
% OUTPUT
% output_stats: a structure with a bunch of information from the lasso
%  fitting

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
t_lasso_start = now;

addpath(fullfile(qilsoftwareroot, 'image_features'));

options = statset('UseParallel', 'Always');
% warning('Parallel disabled');
if matlabpool('size') == 0
  matlabpool('open');
end

%% Parse input arguments
p = inputParser;
p.addParamValue('mcreps', 10); % Number of Monte Carlo cross validation repetitions
p.addParamValue('alpha', 1); % 1=lasso, 0=ridge, in between=elastic net
p.addParamValue('num_categories', []);
p.addParamValue('b_verbose', true);
p.addParamValue('b_plot', true);
p.addParamValue('h_fig', []);
p.parse(varargin{:});
mcreps = p.Results.mcreps;
alpha = p.Results.alpha;
num_categories = p.Results.num_categories;
b_verbose = p.Results.b_verbose;
b_plot = p.Results.b_plot;
h_fig = p.Results.h_fig;

if isempty(num_categories)
  if iscell(Y) && all(cellfun(@ischar, Y));
    num_categories = length(unique(Y));
  else
    num_categories = 0;
  end
end

%% Run lasso
if num_categories == 0
  % Continuous lasso regression
  
  lasso_type_str = 'lasso';
  [b, fitinfo] = lasso(X, Y, 'cv', 10, 'PredictorNames', X_names, 'MCReps', mcreps, 'Alpha', alpha, 'options', options);
  min_error = fitinfo.MSE(fitinfo.IndexMinMSE);
  min_plus_1SE_error = fitinfo.MSE(fitinfo.Index1SE);
  null_error = fitinfo.MSE(end);
else
  % Binomial or multinomial lasso
  
  if num_categories == 2
    % Binomial lasso regression

    Y_positive_class_label = get_positive_class_label(Y);
    Y_bino = strcmp(Y, Y_positive_class_label);

    lasso_type_str = 'lassoglm';
    [b, fitinfo] = my_lassoglm(X, Y_bino, 'binomial', 'cv', 10, 'PredictorNames', X_names, 'MCReps', mcreps, 'Alpha', alpha, 'options', options);
    min_error = fitinfo.Deviance(fitinfo.IndexMinDeviance);
    min_plus_1SE_error = fitinfo.Deviance(fitinfo.Index1SE);
    null_error = fitinfo.Deviance(end);
  else
    error('Unsupported number of categories: %d', num_categories);
  end
end

if strcmp(lasso_type_str, 'lassoglm')
  [roc, optimal_pt] = get_roc_info_from_lasso(fitinfo, Y, Y_positive_class_label);
else
  roc = [];
  optimal_pt = [];
end


%% Print some results
if b_verbose
  lasso_print_results(b, fitinfo, X, X_names, Y_name, mcreps, lasso_type_str, min_error, min_plus_1SE_error, null_error, roc, optimal_pt, t_lasso_start);
end

%% Make lasso plots
if b_plot
  lasso_make_plots(b, fitinfo, Y_name, lasso_type_str, min_error, min_plus_1SE_error, null_error, h_fig, roc, optimal_pt);
end

%% Output arguments
fitinfo.mcreps = mcreps;
fitinfo.alpha = alpha;

output_stats.b = b;
output_stats.fitinfo = fitinfo;
output_stats.Y = Y;

1;

function [b, fitinfo] = run_binomial_lassoglm(X, Y_bino, cv, X_names, mcreps, alpha, lassoglm_options)
%% Function: run binomial lassoglm

[b, fitinfo] = my_lassoglm(X, Y_bino, 'binomial', 'cv', cv, 'PredictorNames', X_names, 'MCReps', mcreps, 'Alpha', alpha, 'options', lassoglm_options);
