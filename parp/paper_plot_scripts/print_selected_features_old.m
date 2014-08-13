function print_selected_features_old(str_response_type, output_filename)
% Print selected features from each model category

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
close all;

addpath(fullfile(danmatlabroot, 'parp'));
addpath(fullfile(danmatlabroot, 'parp', 'stat_analysis'));

if ~exist('str_response_type', 'var') || isempty(str_response_type)
  str_response_type = 'rcb';
end
if ~exist('b_save', 'var') || isempty(b_save)
  b_save = false;
end

xls_filename = '/Users/dgolden/software/parp/stat_analysis/Lasso Regression Summary Table.xlsx';
lasso_run_dir = '/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs';
output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');

if strcmp(str_response_type, 'rcb')
  sheet_name = 'RCB';
  results_to_report = {'rcb_pcr', 'rcb_gt25'};
  plot_titles = {'Predict pCR (RCB=0)', 'Predict RCB > 2.5'};
elseif strcmp(str_response_type, 'tumor_and_nodes')
  sheet_name = 'Tumor and Nodes';
  results_to_report = {'nodes', 'tumor', 'nodes_and_tumor'};
  plot_titles = {'Predict residual nodes', 'Predict residual tumor', 'Predict residual tumor and nodes'};
end

%% Load spreadsheet data
[run_filenames, pretty_names] = get_run_filenames_from_one_sheet(xls_filename, sheet_name);

%% Collect file data
results = struct('lr', {}, 'auc', {}, 'str', {}, 'response', {}, 'pretty_name', {});

min_auc = 0.6;

for kk = 1:length(run_filenames)
  fs = load(fullfile(lasso_run_dir, run_filenames{kk}));
  
  for jj = 1:length(results_to_report)
    result_idx = length(results) + 1;
    this_result = fs.results.(results_to_report{jj}).lasso;
    
    [roc, optimal_pt] = get_roc_info_from_lasso(this_result.fitinfo, this_result.Y, get_positive_class_label(this_result.Y));
    auc = mean([roc.AUC]);
    
    if auc < min_auc
      continue;
    end
    
    % Print result name and num patients
    str = sprintf('%s --> %s: n=%d, ROC AUC = %0.2f\n', pretty_names{kk}, get_positive_class_label(this_result.Y), length(this_result.Y), auc);
    
    b_selected = this_result.b(:, this_result.fitinfo.Index1SE);
    feature_idx = find(b_selected ~= 0);
    
    clear features;
    for ii = 1:length(feature_idx)
      this_feature_name = fs.X_names{feature_idx(ii)};
      coeff = b_selected(feature_idx(ii));
      feature_std = std(fs.X(:,feature_idx(ii)));
      
      % Don't include features where b*std < threshold
      if abs(coeff*feature_std) < 0.05
        continue;
      end
      
      str = [str sprintf(' %+8.3G (b*std = %+0.3f): %s\n', coeff, coeff*feature_std, this_feature_name)];
      
      features(ii).name = this_feature_name;
      features(ii).coeff = coeff;
      features(ii).std = feature_std;
      features(ii).coeff_std = coeff*feature_std;
    end
    features(cellfun(@isempty, {features.name})) = [];
    
    str = [str sprintf('\n')];
    
    results(result_idx).auc = auc;
    results(result_idx).lr = this_result;
    results(result_idx).str = str;
    results(result_idx).response = results_to_report{jj};
    results(result_idx).response_pretty = get_positive_class_label(this_result.Y);
    results(result_idx).pretty_name = pretty_names{kk};
    results(result_idx).features = features;
  end
end

%% Custom sort by the order in my paper
sort_order = {'All Clinical'
              'All Clinical but Ki67'
              'Ki67'
              'GLCM Pre-chemo'
              'GLCM Post-chemo'
              'GLCM Pre- and GLCM Post-chemo'
              'Patterns of Response'
              'BI-RADS'
              'GLCM Pre-chemo and BI-RADS'};

for kk = 1:length(results)
  results(kk).weight = find(strcmp(sort_order, {results(kk).pretty_name}));
end
[~, sort_idx] = sort([results.weight]);
results = results(sort_idx);

% for kk = 1:length(results)
%   fprintf('%s --> %s\n', results(kk).pretty_name, results(kk).response);
% end

%% Print
if exist('output_filename', 'var') && ~isempty(output_filename)
  % Write output to file
  fid = fopen(output_filename, 'w');
else
  fid = 1;
end

for kk = 1:length(results)
  tee(results(kk).str, fid);
end

if fid ~= 1
  fclose(fid);
  fprintf('Saved %s\n', output_filename);
end

%% Plot
figure(1);
figure_grow(gcf, 1, 1);
ax_xpos = 0.5; % x position
ax_xpos(2) = 0.9 - ax_xpos(1); % width

for kk = 1:length(results)
  sfigure(1);
  clf;
  
  % Plot AUC
  s(1) = axes('position', [ax_xpos(1) 0.8 ax_xpos(2) 0.05]);
  barh(1, results(kk).auc, 'r');
  xlim([0.5 1]);
  set(gca, 'ytick', 1, 'yticklabel', 'AUC', 'xaxisLocation', 'top', 'xtick', [0.5 0.75 1]);
  % title(sprintf('%s --> %s', results(kk).pretty_name, results(kk).response_pretty))
  title(sprintf('%s', strrep(results(kk).pretty_name, 'chemo', 'chemotherapy')))
  grid on;
  
  % Sort features by "importance"
  [~, sort_idx] = sort([results(kk).features.coeff_std], 'descend');
  features_sorted = results(kk).features(sort_idx);

  % Squish feature axis so different axes with different numbers of
  % features have common height per feature
  height_per_feature = 0.05;
  ax_height = height_per_feature*length(features_sorted) + 0.05;
  ax_y = 0.79 - ax_height;
  
  % Plot features
  s(2) = axes('position', [ax_xpos(1) ax_y ax_xpos(2) ax_height]);
  barh(1:length(features_sorted), [features_sorted.coeff_std], 'facecolor', 'k');
  set(gca, 'ytick', 1:length(features_sorted), 'yticklabel', feature_renamer({features_sorted.name}));
  xlabel('b*std');
  xl = xlim;
  xlim([-1 1]*max(abs(xl)));
  ylim([0 length(features_sorted) + 1]);
  grid on;
  
  increase_font;

  output_filename = sprintf('raw_features_%s_%02d_%s', results(kk).response, kk, sanitize_struct_fieldname(results(kk).pretty_name));
  
  paper_print(output_filename, 10, 2, output_dir);
end

function [run_filenames, pretty_names] = get_run_filenames_from_one_sheet(xls_filename, sheet_name)
[~, ~, raw] = xlsread(xls_filename, sheet_name);
column_names = raw(1,:);

run_filenames = raw(2:end, strcmp(column_names, 'Run Filename'));
pretty_names = raw(2:end, strcmp(column_names, 'Pretty Name'));
b_include = cell2mat(raw(2:end, strcmp(column_names, 'Include')));

idx_valid = cellfun(@(x) ischar(x) && ~isempty(x), run_filenames) & b_include;
run_filenames = run_filenames(idx_valid);
pretty_names = pretty_names(idx_valid);

function tee(str, fid)
% Write to console and file

if exist('fid', 'var') && ~isempty(fid) && fid ~= 1
  fprintf(fid, str);
end

fprintf(str);

function feature_names = feature_renamer(feature_names)
% Make feature names prettier

feature_names = strrep(feature_names, '_', ' ');
feature_names = strrep(feature_names, 'glcm', 'GLCM');
feature_names = strrep(feature_names, 'pre', 'pre-chemo');
feature_names = strrep(feature_names, 'post', 'post-chemo');
feature_names = strrep(feature_names, 'birads', 'BI-RADS');
feature_names = strrep(feature_names, 'ktrans', 'Ktrans');
feature_names = strrep(feature_names, 'mass shape none', 'non-mass-like');
feature_names = strrep(feature_names, 'area under curve', 'AUC');
feature_names = strrep(feature_names, 'auc', 'AUC');
feature_names = strrep(feature_names, 'cycles of treatment received 4 (all possible cycles)', '4 treatment cycles');
feature_names = strrep(feature_names, 'cycles of treatment received 6 (all possible cycles)', '6 treatment cycles');
feature_names = strrep(feature_names, 'stage ia iiia', 'stage');
feature_names = strrep(feature_names, 'TNM N', 'TNM');
feature_names = strrep(feature_names, 'TNM T', 'TNM');
feature_names = strrep(feature_names, 'brca', 'BRCA');
feature_names = strrep(feature_names, 'Negative', 'negative');
feature_names = strrep(feature_names, 'Positive', 'positive');
feature_names = strrep(feature_names, 'er ', 'ER ');


for kk = 1:length(feature_names)
  if (~isempty(strfind(feature_names{kk}, 'GLCM')) || ~isempty(strfind(feature_names{kk}, 'avg'))) && ...
      isempty(strfind(feature_names{kk}, 'post')) && isempty(strfind(feature_names{kk}, 'pre'))
    % The early days of GLCM where everything was pre-chemo, but I forgot
    % to annotate the features as such
    feature_names{kk} = [feature_names{kk} ' pre-chemo'];
  end
end
