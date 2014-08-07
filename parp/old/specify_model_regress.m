function [x_idx, b] = specify_model_regress(x_full, y, x_names, varargin)
% Specify a multiple regression model; choose features via sequential
% feature selection with 10-fold cross-validation
% 
% [x_idx, b] = specify_model_regress(x_full, y, 'param', value, ...)
% 
% INPUTS
% x_full: NxM matrix of N measurements of M candidate features
% y: Nx1 matrix of N outputs
% 
% PARAMETERS:
% max_num_features: maximum number of features for the model to select
%  (default: Inf)
% b_verbose: print some stuff about the model (default: false)
% 
% OUTPUTS:
% x_idx: indices of selected features from x_full (i.e., x_full(x_idx,:))
% b: regression coefficients; b(1) is the constant

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Setup
p = inputParser;
p.addParamValue('max_num_features', inf);
p.addParamValue('b_verbose', false);
p.parse(varargin{:});
max_num_features = p.Results.max_num_features;
b_verbose = p.Results.b_verbose;

%% Parallel
b_parallel = false;
if b_parallel
  opts = statset('useparallel', 'always', 'UseSubstreams', 'always', 'Streams', RandStream('mlfg6331_64'));
  
  if matlabpool('size') == 0
    matlabpool('open');
  end
else
  opts = statset;
end

%% Feature selection
% Features without much variation (e.g., num treatment cycles) lead to singular matrix warnings
s_singular = warning('off', 'MATLAB:singularMatrix');
s_rank_deficient = warning('off', 'MATLAB:rankDeficientMatrix');
[inmodel, history] = my_sequentialfs(@crossval_fun_regress, x_full, y, 'cv', min(10, length(y)), 'options', opts);
warning(s_singular.state, 'MATLAB:singularMatrix');
warning(s_rank_deficient.state, 'MATLAB:rankDeficientMatrix');

% Get list of features in the order they were selected
inmodel_sorted = get_selected_feature_order(history);

% Print
if b_verbose
  x_names_selected = x_names(inmodel_sorted);
  fprintf('Chose features:\n');
  for kk = 1:length(x_names_selected)
    fprintf('%02d %s\n', kk, x_names_selected{kk});
  end
  fprintf('\n');
end

% Choose up to max_num_features features
model_feature_idx = 1:min(length(inmodel_sorted), max_num_features);

%% Run model
x_idx = inmodel_sorted(model_feature_idx);
x_selected = x_full(:, x_idx);

b = [ones(size(y)) x_selected]\y;
