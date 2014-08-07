function varargout = RunRanksum(obj, varargin)
% Run ranksum test to get p-values for each feature
% p_val = RunRanksum(obj, 'param', value, ...)
% 
% PARAMETERS
% b_print: print results
% b_print_only_significant: false (default) to print all p-values; true to print only
%  p-values < 0.05
% b_print_sort_by_p: true (default) to sort the printed (but not the returned) output by
% p-value in ascending order

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_print', true);
p.addParamValue('b_print_only_significant', false);
p.addParamValue('b_print_sort_by_p', true);
p.parse(varargin{:});

%% Setup
error('Wilcoxon rank sum test is not appropriate for longitudinal data');

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
  
  x1 = x1(~isnan(x1));
  x2 = x2(~isnan(x2));
  
  if isempty(x1) || isempty(x2)
    p_val(kk) = nan;
    continue;
  end    
  
  [p_val(kk), ~, stats] = ranksum(x1, x2);
end

%% Print p-values
if p.Results.b_print
  feature_num = 1:length(obj.FeatureNames);
  if p.Results.b_print_sort_by_p
    [p_sort, idx_p] = sort(p_val);
  else
    p_sort = p_val;
    idx_p = 1:length(p_val);
  end
  
  X_names_p_sort = obj.FeatureNames(idx_p);
  feature_num_p_sort = feature_num(idx_p);
  for kk = 1:length(p_sort)
    if p_sort(kk) <= 0.05 || ~p.Results.b_print_only_significant
      fprintf('ranksum %s vs %s: %s (feature %d) p=%0.5G\n', response_unique{1}, response_unique{2}, X_names_p_sort{kk}, feature_num_p_sort(kk), p_sort(kk));
    end
  end
end

% if ~any(p_sort(kk) <= 0.05)
%   fprintf('No significant features via ranksum test\n');
% end

%% Assign output arguments
if nargout > 0
  varargout{1} = p_val;
end
