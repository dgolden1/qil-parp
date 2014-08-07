function varargout = RunRanksum(obj, varargin)
% Run ranksum test to get p-values for each feature
% p_val = FeatureSet(obj, 'param', value, ...)
% 
% PARAMETERS
% b_print_only_significant: false (default) to print all p-values; true to print only
% p-values < 0.05

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_print_only_significant', false); 
p.parse(varargin{:});

%% Setup
response_unique = unique(obj.Response);
if length(response_unique) ~= 2
  error('Response should have exactly two unique values');
end

%% Run test
p_val = zeros(1, length(obj.FeatureNames));
for kk = 1:length(obj.FeatureNames)
  % Two-sided p value is computed as
  % p = 2*(1 - normcdf(abs(stats.zval)))
  % Which is the area under outside of normal curve when cut on both sides
  % at z = stats.zval
  % One-sided p value is computed as
  % p = 1 - normcdf(abs(stats.zval))
  % Which is area under outside of normal curve when cut on only one side
  % 
  % We need to use the two-sided test when we don't know
  % a priori which category will have higher values of the feature
  
  x1 = obj.FeatureVector(strcmp(obj.Response, response_unique{1}), kk);
  x2 = obj.FeatureVector(strcmp(obj.Response, response_unique{2}), kk);
  
  % According to the Matlab documentation, the kstest is not valid if
  % this condition is not true
  if length(x1)*length(x2)/(length(x1) + length(x2)) >= 4
    [~, p_val(kk), stats] = kstest2(x1, x2);
  else
    p_val(kk) = nan;
  end
end

%% Print p-values
feature_num = 1:length(obj.FeatureNames);
[p_sort, idx_p] = sort(p_val);
X_names_p_sort = obj.FeatureNames(idx_p);
feature_num_p_sort = feature_num(idx_p);
for kk = 1:length(p_sort)
  if p_sort(kk) <= 0.05 || ~p.Results.b_print_only_significant
    fprintf('Kolmogorov-Smirnov %s vs %s: %s (feature %d) p=%0.5G\n', response_unique{1}, response_unique{2}, X_names_p_sort{kk}, feature_num_p_sort(kk), p_sort(kk));
  end
end

% if ~any(p_sort(kk) <= 0.05)
%   fprintf('No significant features via ranksum test\n');
% end

%% Assign output arguments
if nargout > 0
  varargout{1} = p_val;
end
