function varargout = PlotCoefficients(obj, varargin)
% Plot model feature coefficients
% s = PlotCoefficients(obj, varargin)
% 
% s is a two-element vector with handles to the AUC and feature axes

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Input arguments
p = inputParser;
p.addParamValue('b_response_in_title', true);
p.addParamValue('b_std_thresh', 0); % Only plot features whos b*std values are above this threshold
p.parse(varargin{:});

%% Select relevant features
b_full = obj.b(:,obj.fitinfo.Index1SE);
b_cv = cell2mat(obj.fitinfo.CVcoefficients(:,obj.fitinfo.Index1SE).');
feature_stds = std(obj.ThisFeatureSet.FeatureVector).';

% The intercept is included in b_cv; remove it
b_cv = b_cv(2:end, :);

% Get the measure of the strength of each feature: b (the coefficient) time the
% feature's standard deviation
bstd_full = b_full .* feature_stds;
bstd_cv = b_cv .* repmat(feature_stds, 1, size(b_cv, 2));

chosen_feature_idx = find(abs(bstd_full) > p.Results.b_std_thresh);

if isempty(chosen_feature_idx)
  error('No features chosen for this model');
end

%% Make a struct with date from the relevant features
[~, sort_idx] = sort(bstd_full(chosen_feature_idx));
[~, feature_rank] = sort(sort_idx);

for kk = 1:length(chosen_feature_idx)
  this_idx = chosen_feature_idx(kk);
  features(feature_rank(kk)).name = obj.ThisFeatureSet.FeaturePrettyNames{this_idx};
  features(feature_rank(kk)).bstd_full = bstd_full(this_idx);
  features(feature_rank(kk)).bstd_cv_mean = mean(bstd_cv(this_idx,:));
  features(feature_rank(kk)).bstd_cv_std = std(bstd_cv(this_idx,:));
end

%% Plot full coefficient values
figure
figure_grow(gcf, 1.8, 1);
ax_xpos = 0.67; % x position
ax_xpos(2) = 0.9 - ax_xpos(1); % width

% Plot AUC
s(1) = axes('position', [ax_xpos(1) 0.8 ax_xpos(2) 0.05]);
barh(1, obj.AUC, 'r');
xlim([0.5 1]);
set(gca, 'ytick', 1, 'yticklabel', 'AUC', 'xaxisLocation', 'top', 'xtick', [0.5 0.75 1], 'tag', 'auc');
% grid on;

% Print actual AUC value
if obj.AUC < 0.85
  auc_label_x = obj.AUC + 0.02;
  auc_label_horizontalalignment = 'left';
else
  auc_label_x = obj.AUC - 0.02;
  auc_label_horizontalalignment = 'right';
end
text(auc_label_x, 1.1, sprintf('%0.2f', obj.AUC), 'horizontalalignment', auc_label_horizontalalignment, 'verticalalignment', 'middle');

title_str = obj.ThisFeatureSet.FeatureCategoryPrettyName;
if p.Results.b_response_in_title
  title_str = [title_str sprintf(' --> %s', obj.YPositiveClassLabel)];
end
title(title_str);

% Squish feature axis so different axes with different numbers of
% features have common height per feature
height_per_feature = 0.05;
ax_height = height_per_feature*length(features) + 0.05;
ax_y = 0.79 - ax_height;

% Plot features
s(2) = axes('position', [ax_xpos(1) ax_y ax_xpos(2) ax_height]);
barh(1:length(features), [features.bstd_full], 'facecolor', 'k');
set(gca, 'ytick', 1:length(features), 'yticklabel', {features.name}, 'tag', 'features');
xlabel('b*std');
ylim([0 length(features) + 1]);
grid on;

increase_font;

%% Plot error bars
hold on;
for kk = 1:length(features)
  error_lim = features(kk).bstd_cv_mean + [-1 1]*features(kk).bstd_cv_std*1.96;
  plot(error_lim, kk*[1 1], 'color', [1 1 1]*0.5, 'linewidth', 2);
end

xlim auto;
xlim([-1 1]*max(abs(xlim)));

%% Output arguments
if nargout > 0
  varargout{1} = s;
end

1;
