function b = specify_model_lasso(x_full, y, x_names)
% Specify a model using lasso regression
% b = specify_model_lasso(x_full, y, x_names)
% 
% b will have size Nx1, the same number of rows as x_full has columns
% b can be applied directly to the full x, since some elements of b will be
% 0

% By Daniel Golden (dgolden1 at stanford dot edu) June 2012
% $Id$

%% Setup
b_debug = false;

%% Fit
[b_all, fitinfo] = lasso(x_full, y, 'cv', 10);

% Choose the coefficients that have the largest lambda (fewest nonzero
% predictors) with cross-validation MSE within 1 standard error of the lambda
% that yields the lowest cross-validation MSE
b = [fitinfo.Intercept(fitinfo.Index1SE); b_all(:, fitinfo.Index1SE)];

%% Debug
if b_debug
  lassoPlot(b_all, fitinfo,'PlotType','CV');
  lassoPlot(b_all, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log')
end

1;
