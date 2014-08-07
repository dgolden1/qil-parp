function plot_lasso_results_forest(str_response_type, b_save)
% Plot a summary of all of the lasso results in a forest-type plot

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
close all;

addpath(fullfile(qilsoftwareroot, 'parp'));

if ~exist('str_response_type', 'var') || isempty(str_response_type)
  str_response_type = 'rcb';
end
if ~exist('b_save', 'var') || isempty(b_save)
  b_save = false;
end

xls_filename = '/Users/dgolden/software/parp/stat_analysis/Lasso Regression Summary Table.xlsx';
lasso_run_dir = '/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs';
output_dir = '~/temp';

if strcmp(str_response_type, 'rcb')
  sheet_name = 'RCB';
  results_to_report = {'rcb_pcr', 'rcb_gt25'};
  plot_titles = {'Predict pCR (RCB=0)', 'Predict RCB > 2.5'};
elseif strcmp(str_response_type, 'tumor_and_nodes')
  sheet_name = 'Tumor and Nodes';
  results_to_report = {'nodes', 'tumor', 'tumor_and_nodes'};
  plot_titles = {'Predict residual nodes', 'Predict residual tumor', 'Predict residual tumor and nodes'};
end

%% Load spreadsheet data
[~, ~, raw] = xlsread(xls_filename, sheet_name);
column_names = raw(1,:);

run_filenames = raw(2:end, strcmp(column_names, 'Run Filename'));
pretty_names = raw(2:end, strcmp(column_names, 'Pretty Name'));
b_include = cell2mat(raw(2:end, strcmp(column_names, 'Include')));

idx_valid = cellfun(@(x) ischar(x) && ~isempty(x), run_filenames) & b_include;
run_filenames = run_filenames(idx_valid);
pretty_names = pretty_names(idx_valid);

%% Collect run data
for kk = 1:length(run_filenames)
  this_run_filename = fullfile(lasso_run_dir, run_filenames{kk});
  fs = load(this_run_filename);
  
  for jj = 1:length(results_to_report)
    this_result = fs.results.(results_to_report{jj}).lasso;
    [roc, optimal_pt] = get_roc_info_from_lasso(this_result.fitinfo, this_result.Y, get_positive_class_label(this_result.Y));
    
    
    results_combined(kk).(results_to_report{jj}).auc = mean(roc.AUC);
    results_combined(kk).(results_to_report{jj}).sensitivity = mean(optimal_pt.sensitivity);
    results_combined(kk).(results_to_report{jj}).specificity = mean(optimal_pt.specificity);
    results_combined(kk).(results_to_report{jj}).name = pretty_names{kk};
    
    % Print num patients
    if jj == 1
      fprintf('%s --> %s: n=%d\n', pretty_names{kk}, str_response_type, length(this_result.Y));
    end
  end
end

%% Plot it
for jj = 1:length(results_to_report)
  this_result_vec = [results_combined.(results_to_report{jj})];
  
  junk_auc_thresh = 0.6; % Threshold for considering an AUC junk

  % str_sort_type = 'auc';
  % str_sort_type = 'name';
  str_sort_type = 'custom';
  
  switch str_sort_type
    case 'auc'
      % Sort by AUC
      [~, sort_idx] = sort([this_result_vec.auc]);
      this_result_vec = this_result_vec(sort_idx);

      % Then, for junk values, sort by name
      junk_idx_temp = [this_result_vec.auc] < junk_auc_thresh;
      [~, sort_idx] = sort({this_result_vec(junk_idx_temp).name});
      sort_idx = sort_idx(end:-1:1); % Reverse sort order because stuff is plotted from the bottom-up
      this_result_vec(junk_idx_temp) = this_result_vec(sort_idx);
    case 'name'
      % Sort by name
      [~, sort_idx] = sort({this_result_vec.name});
      sort_idx = sort_idx(end:-1:1); % Reverse sort order because stuff is plotted from the bottom-up
      this_result_vec = this_result_vec(sort_idx);
    case 'custom'
      % Custom sort by name
      sort_order = {'All Clinical'
                    'All Clinical but Ki67'
                    'Ki67'
                    'GLCM Pre-chemo'
                    'GLCM Post-chemo'
                    'GLCM Pre- and GLCM Post-chemo'
                    'Patterns of Response'
                    'BI-RADS'
                    'GLCM Pre-chemo and BI-RADS'};
                  
      sort_order = flipud(sort_order); % Reverse order since results a plotted from bottom-up         
      assert(length(sort_order) == length(this_result_vec));
      
      old_result_vec = this_result_vec;
      for kk = 1:length(old_result_vec)
        this_result_vec(kk) = old_result_vec(strcmp({old_result_vec.name}, sort_order{kk}));
      end
  end
  
  % Index into sorted results for which results are junk
  junk_idx = [this_result_vec.auc] < junk_auc_thresh;
  
  % Set forest plot parameters
  low_vals = [this_result_vec.sensitivity];
  high_vals = [this_result_vec.specificity];
  dot_vals = [this_result_vec.auc];
  names = {this_result_vec.name};
  
  names = color_names(names);
  
  forest_plot(low_vals, high_vals, dot_vals, names, 'plot_title', plot_titles{jj}, ...
    'legend_names', {'Sensitivity', 'Specificity', 'AUC'}, 'junk_idx', junk_idx);
  xlim([0 1]);
  figure_grow(gcf, 2, 1);
  
  output_filename = fullfile(output_dir, sprintf('lasso_results_%s.png', results_to_report{jj}));
  
  if b_save
    print_trim_png(output_filename);
    fprintf('Saved %s\n', output_filename);
  end
end

function names_colored = color_names(names)
% Assign TeX colors to names for easy viewing

names_colored = names;

names_colored = strrep(names_colored, 'BI-RADS', '\color[rgb]{1,0,1}BI-RADS');
names_colored = strrep(names_colored, 'Patterns of Response', '\color[rgb]{0.5,0,0.5}Patterns of Response');
names_colored = strrep(names_colored, 'Clinical', '\color[rgb]{1,0.5,0}Clinical');
names_colored = strrep(names_colored, 'BRCA', '\color[rgb]{1,0.5,0}BRCA');
names_colored = strrep(names_colored, 'Ki67', '\color[rgb]{1,0.5,0}Ki67');
names_colored = strrep(names_colored, 'Dan''s Semantic', '\color[rgb]{0,0.5,0}Dan''s Semantic');
names_colored = strrep(names_colored, 'GLCM Pre-', '\color[rgb]{0,0.5,1}GLCM Pre');
names_colored = strrep(names_colored, 'GLCM Post-', '\color[rgb]{0,0.5,0.5}GLCM Post');
names_colored = strrep(names_colored, 'JJ', '\color[rgb]{1,0,0}QFP');
names_colored = strrep(names_colored, 'and', '\color[rgb]{0,0,0}and');
names_colored = strrep(names_colored, 'chemo', '');

1;
