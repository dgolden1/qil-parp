function model_jiajings_pipeline
% Model features from Jiajing's quantitative feature pipeline

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
close all;

output_dir = '~/temp/jiajings_features';
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% Get features
[X, X_names, patient_id] = get_jiajings_pipeline_features;

%% Get RCB
si = get_spreadsheet_info(patient_id);
rcb = [si.rcb_value].';
rcb_cat(rcb == 0) = {sprintf('pCR (%d)', sum(rcb == 0))};
rcb_cat(rcb > 0 & rcb < 2.5) = {sprintf('0<RCB<2.5 (%d)', sum(rcb > 0 & rcb < 2.5))};
rcb_cat(rcb >= 2.5) = {sprintf('RCB>=2.5 (%d)', sum(rcb >= 2.5))};

%% Make a bunch of box-whisker plots
% figure;
% for kk = 1:length(X_names)
%   t_start = now;
% 
%   clf;
%   boxplot(X(:,kk), rcb_cat, 'positions', 3:-1:1); % Set positions so pCR is left, RCB>2.5 is right
%   title(sprintf('%s (feat %d)', X_names{kk}, kk));
%   increase_font;
%   
%   output_filename = fullfile(output_dir, sprintf('jj_feat_%03d', kk));
%   print_trim_png(output_filename);
%   
%   fprintf('Wrote %s (%d of %d) in %s\n', output_filename, kk, length(X_names), time_elapsed(t_start, now));
% end

%% Perform Wilcoxon rank-sum test for pCR and RCB>2.5 categories
p_pcr = zeros(length(X_names), 1);
p_rcb25 = zeros(length(X_names), 1);
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
  
  [p_pcr(kk), ~, stats] = ranksum(X(rcb == 0, kk), X(rcb > 0, kk));
  [p_rcb25(kk), ~, stats] = ranksum(X(rcb < 2.5, kk), X(rcb >= 2.5, kk));
end

% Print significant p-values for pCR ranksum test
feature_num = 1:length(X_names);
[p_pcr_sort, idx_p_pcr] = sort(p_pcr);
X_names_p_pcr_sort = X_names(idx_p_pcr);
feature_num_p_pcr_sort = feature_num(idx_p_pcr);
for kk = 1:length(p_pcr_sort)
  if p_pcr_sort(kk) <= 0.05
    fprintf('ranksum pCR %s (feature %d) p=%0.5G\n', X_names_p_pcr_sort{kk}, feature_num_p_pcr_sort(kk), p_pcr_sort(kk));
  end
end

% Print significant p-values for RCB>2.5 ranksum test
[p_rcb25_sort, idx_p_rcb25] = sort(p_rcb25);
X_names_p_rcb25_sort = X_names(idx_p_rcb25);
feature_num_p_rcb25_sort = feature_num(idx_p_rcb25);
for kk = 1:length(p_rcb25_sort)
  if p_rcb25_sort(kk) <= 0.05
    fprintf('ranksum RCB>=2.5 %s (feature %d) p=%0.5G\n', X_names_p_rcb25_sort{kk}, feature_num_p_rcb25_sort(kk), p_rcb25_sort(kk));
  end
end

%% Run lasso to predict continuous RCB
[b, fitinfo] = lasso(X, rcb, 'cv', 10);

lassoPlot(b, fitinfo,'PlotType','CV');
title(sprintf('Predict RCB Continuous'));
increase_font
print_trim_png('~/temp/lasso_rcb_cont_cv');

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log')
title(sprintf('Predict RCB Continuous'));
increase_font(gcf, 14);
print_trim_png('~/temp/lasso_rcb_cont_lambda');

%% Run lasso to predict RCB == 0
[b, fitinfo] = lassoglm(X, rcb == 0, 'binomial', 'cv', 10);

lassoPlot(b, fitinfo,'PlotType','CV');
title('Predict RCB=0');
increase_font
print_trim_png('~/temp/lasso_rcb_eq_0_cv');

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log');
title('Predict RCB=0');
increase_font(gcf, 14);
print_trim_png('~/temp/lasso_rcb_eq_0_lambda');

%% Run lasso to predict RCB >= 2.5
[b, fitinfo] = lassoglm(X, rcb >=2.5, 'binomial', 'cv', 10);

lassoPlot(b, fitinfo,'PlotType','CV');
title('Predict RCB>2.5');
increase_font
print_trim_png('~/temp/lasso_rcb_gt_25_cv');

lassoPlot(b, fitinfo, 'PlotType', 'Lambda', 'xscale', 'log');
title('Predict RCB>2.5');
increase_font(gcf, 14);
print_trim_png('~/temp/lasso_rcb_gt_25_lambda');

1;
