function varargout = RunCoxPH(obj, varargin)
% Run cox proportional hazards regression get coefficients and p-values for each feature
% [b, p] = RunCoxPH(obj, 'param', value, ...)
% 
% PARAMETERS
% b_print: print results
% b_print_only_significant: false (default) to print all p-values; true to print only
%  p-values < 0.05
% b_print_sort_by_p: true (default) to sort the printed (but not the returned) output by
% p-value in ascending order
% b_run_separately: if false (default) creates a combined model with all features; if
%  true, creates a separate model for each feature. Separate models will not properly
%  account for correlation between features, but will be more similar to single-feature
%  tests, like the ranksum test
% survival_time: provide survival time; otherwise, FeatureSet.Response is assumed to be
%  the survival time
% censoring: logical vector of same length as number of patients; true for censored
%  patients, false for patients who experienced an event

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_print', true);
p.addParamValue('b_print_only_significant', false);
p.addParamValue('b_print_sort_by_p', true);
p.addParamValue('b_run_separately', false);
p.addParamValue('survival_time', []);
p.addParamValue('censoring', false(length(obj.Response), 1));
p.parse(varargin{:});

%% Get survival time
if isempty(p.Results.survival_time)
  survival_time = obj.Response(:);
else
  survival_time = p.Results.survival_time(:);
end

if ~isnumeric(survival_time) || length(unique(survival_time)) <= 3
  error('Survival time must be a numeric array of times');
end

%% Run with all features together
if ~p.Results.b_run_separately
  [b, logl, H, stats] = coxphfit(obj.FeatureVector, survival_time, 'censoring', p.Results.censoring);
  p_val = stats.p;
end

%% Run with all features separately
if p.Results.b_run_separately
  b = nan(length(obj.FeatureNames), 1);
  p_val = nan(length(obj.FeatureNames), 1);

  for kk = 1:length(b)
    this_feature = obj.FeatureVector(:,kk);
    if nanstd(this_feature)/abs(nanmean(this_feature)) < 1e-3
      fprintf('DEBUG: not testing %s because std/mean < 1e-3\n', obj.FeaturePrettyNames{kk});
      b(kk) = nan;
      p_val(kk) = nan;
      continue;
    end
    this_feature_norm = (this_feature - nanmean(this_feature))/nanstd(this_feature);
    [this_b, logl, H, stats] = coxphfit(this_feature_norm, survival_time, 'censoring', p.Results.censoring);
    b(kk) = this_b;
    p_val(kk) = stats.p;
  end
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
      fprintf('Cox regression: %s (feature %d) p=%0.5G\n', X_names_p_sort{kk}, feature_num_p_sort(kk), p_sort(kk));
    end
  end
end

%% Output arguments
if nargout > 0
  varargout{1} = b;
  varargout{2} = p_val;
end
