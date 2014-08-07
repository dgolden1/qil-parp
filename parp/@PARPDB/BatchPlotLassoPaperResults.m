function BatchPlotLassoPaperResults(b_save)
% Plot results created with PARPDB.batch_run_models_for_paper via the forest plot

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Setup
close all;

if ~exist('b_save', 'var') || isempty(b_save)
  b_save = false;
end

lasso_run_dir = '/Users/dgolden/Documents/qil/case_studies/parp/stat_analysis_runs/paper_rev_2';
output_dir = '~/temp';

plot_titles = {'Predict pCR (RCB=0)', 'Predict RCB > 2.5', 'Predict residual tumor', 'Predict residual nodes', 'Predict residual tumor and nodes'};


%% Collect run data
d = dir(fullfile(lasso_run_dir, '*.mat'));

for kk = 1:length(d)
  reg_tok = regexp(d(kk).name, '(?:lasso_run_)(.*)(?:\.mat)', 'tokens');
  feature_set_names{kk} = reg_tok{1}{1};
  
  lasso_filename = fullfile(lasso_run_dir, d(kk).name);
  load(lasso_filename, 'lasso_runs');
  
  for jj = 1:length(lasso_runs)
    this_response = sanitize_struct_fieldname(lasso_runs(jj).YName);
    
    results_combined(kk).(this_response).auc = lasso_runs(jj).AUC;
    results_combined(kk).(this_response).auc_std = std(lasso_runs(jj).ROC.AUC);
    results_combined(kk).(this_response).sensitivity = lasso_runs(jj).Sensitivity;
    results_combined(kk).(this_response).specificity = lasso_runs(jj).Specificity;
    results_combined(kk).(this_response).name = feature_set_names{kk};
    
    % Print num patients
    if jj == 1
      fprintf('%s: n=%d\n', feature_set_names{kk}, length(lasso_runs(jj).ThisFeatureSet.PatientIDs));
    end
  end
end

%% Plot it
fn = fieldnames(results_combined);
for jj = 1:length(fn)
  this_result_vec = [results_combined.(fn{jj})];
  
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
      sort_order_pretty = {'All Clinical'
                           'All Clinical but Ki67'
                           'GLCM Pre-chemo'
                           'GLCM Post-chemo'
                           'GLCM Pre- and GLCM Post-chemo'
                           'Patterns of Response'
                           'BI-RADS'
                           'GLCM Pre-chemo and BI-RADS'};

      sort_order = {'clinical_all'
                    'clinical_all_but_ki67'
                    'glcm_pre'
                    'glcm_post'
                    'glcm_both'
                    'patterns_of_response'
                    'birads'
                    'glcm_pre_and_birads'};
                  
      % Reverse order since results a plotted from bottom-up         
      sort_order = flipud(sort_order);
      sort_order_pretty = flipud(sort_order_pretty);
      assert(length(sort_order) == length(this_result_vec));
      
      old_result_vec = this_result_vec;
      for kk = 1:length(old_result_vec)
        idx = strcmp({old_result_vec.name}, sort_order{kk});
        assert(sum(idx) == 1);
        this_result_vec(kk) = old_result_vec(idx);
        
        % Replace name with pretty name
        this_result_vec(kk).name = sort_order_pretty{strcmp(sort_order, this_result_vec(kk).name)};
      end
  end
  
  % Index into sorted results for which results are junk
  junk_idx = [this_result_vec.auc] < junk_auc_thresh;
  
  % Set forest plot parameters: AUC, sensitivity, specificity
  % low_vals = [this_result_vec.sensitivity];
  % high_vals = [this_result_vec.specificity];
  % legend_names = {'Sensitivity', 'Specificity', 'AUC'};
  low_vals = [this_result_vec.auc] - 1.96*[this_result_vec.auc_std];
  high_vals = [this_result_vec.auc] + 1.96*[this_result_vec.auc_std];
  legend_names = {'95% CI', 'AUC'};
  dot_vals = [this_result_vec.auc];
  names = {this_result_vec.name};
  
  % Replace names with pretty names
  names = color_names(names);
  
  % Plot
  forest_plot(low_vals, high_vals, dot_vals, names, 'plot_title', plot_titles{jj}, ...
    'legend_names', legend_names, 'low_plot_params', [], 'high_plot_params', [], 'junk_idx', junk_idx);
  
  xlim([0 1]);
  figure_grow(gcf, 2, 1);
  
  output_filename = fullfile(output_dir, sprintf('lasso_results_%s.png', fn{jj}));
  
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
