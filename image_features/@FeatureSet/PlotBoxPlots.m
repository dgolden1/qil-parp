function PlotBoxPlots(obj, varargin)
% Plot box-whisker plots
% PlotBoxPlots(obj, varargin)
% 
% PARAMETERS
% output_dir (default: '~/temp/feature_boxplots')
%  NOTE: everything in output_dir will be deleted
% feature_names: plot only a subset of features
% b_all_points: true to also plot all points
% b_notch: plot the notch in the boxes
% b_save_plots: save the plots

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

% Two scenarios: comparing continuous feature values for different
% categories of response, or comparing continuous response values for
% different feature categories

%% Parse input arguments
p = inputParser;
p.addParamValue('output_dir', '~/temp/feature_boxplots');
p.addParamValue('feature_names', {});
p.addParamValue('b_all_points', false);
p.addParamValue('b_notch', true);
p.addParamValue('b_save_plots', true);
p.parse(varargin{:});
output_dir = p.Results.output_dir;

%% Setup
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
else
  % Remove existing boxplots
  d = dir(output_dir);
  d = d(cellfun(@(x) x(1) ~= '.', {d.name}));
  for kk = 1:length(d)
    delete(fullfile(output_dir, d(kk).name));
  end
end

%% Ensure features are continuous and response is categorical
% Get rid of categorical features
b_feature_categorical = BFeaturesCategorical(obj);
obj = RemoveFeatures(obj, obj.FeatureNames(b_feature_categorical));

if length(obj.FeatureNames) == 0
  error('All features are categorical');
end

if iscell(obj.Response) && all(cellfun(@isempty, obj.Response))
  error('Response is undefined');
elseif length(unique(obj.Response)) ~= 2
  error('Response must have exactly two unique values; length(unique(response)) = %d', length(unique(obj.Response)));
end

if ~iscellstr(obj.Response)
  response_cellstr(obj.Response == 0) = {sprintf('%s (%d)', ['Not ' obj.ResponseName], sum(obj.Response == 0))};
  response_cellstr(obj.Response == 1) = {sprintf('%s (%d)', obj.ResponseName, sum(obj.Response == 1))};
else
  response_cellstr = obj.Response;
  response_unique = unique(response_cellstr);
  for kk = 1:length(response_unique)
    this_idx = strcmp(response_cellstr, response_unique{kk});
    response_cellstr(this_idx) = {sprintf('%s (%d)', response_unique{kk}, sum(this_idx))};
  end
end

%% Select a subset of features
if ~isempty(p.Results.feature_names)
  if ischar(p.Results.feature_names)
    feature_names_requested = {p.Results.feature_names};
  else
    feature_names_requested = p.Results.feature_names;
  end
  
  % Allow user to select feature names via the internal name or the pretty name, but
  % then homogenize them to be the internal name
  feature_idx = ismember(obj.FeatureNames, feature_names_requested) | ismember(obj.FeaturePrettyNames, feature_names_requested);
  feature_names_requested = obj.FeatureNames(feature_idx);
else
  feature_names_requested = obj.FeatureNames;
end

%% Make plots
% Make a pair of box-whisker plots for each feature representing feature
% values for each response category
  
if p.Results.b_notch
  notch_str = 'on';
else
  notch_str = 'off';
end

figure;

for kk = 1:length(feature_names_requested)
  t_start = now;
  
  feature_idx = find(strcmp(obj.FeatureNames, feature_names_requested{kk}));

  if p.Results.b_save_plots
    clf;
  elseif kk > 1
    figure;
  end
  
  boxplot(obj.FeatureVector(:,feature_idx), response_cellstr, 'notch', notch_str);
  title(sprintf('%s (feature %d)', obj.FeaturePrettyNames{feature_idx}, feature_idx));
  increase_font;
  
  if p.Results.b_all_points
    hold on;
    response_unique = unique(obj.Response);
    for jj = 1:length(response_unique)
      these_vals = obj.FeatureVector(strcmp(obj.Response, response_unique{jj}),feature_idx);
      plot(jj*ones(length(these_vals), 1), these_vals, '*', 'color', [0 0.5 0]);
    end
  end

  if p.Results.b_save_plots
    output_filename = fullfile(output_dir, sprintf('feature_%03d_%s', feature_idx, obj.FeatureNames{feature_idx}));
    print_trim_png(output_filename);
    fprintf('Wrote %s (%d of %d) in %s\n', output_filename, kk, length(feature_names_requested), time_elapsed(t_start, now));
  end
end  
