function plot_selected_features
% Print selected features from each model category

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

%% Setup
close all;

lasso_run_dir = fullfile(qilcasestudyroot, 'parp', 'stat_analysis_runs', 'paper_rev_2');
output_dir = fullfile(dandropboxroot, 'papers', '2012_breast_cancer_heterogeneity_and_rcb', 'images');

%% Sort order

sort_order = {'clinical_all'
              'clinical_all_but_ki67'
              'glcm_pre'
              'glcm_post'
              'glcm_both'
              'patterns_of_response'
              'birads'
              'glcm_pre_and_birads'};


%% Collect run data
d = dir(fullfile(lasso_run_dir, '*.mat'));

for kk = 1:length(d)
  close all;
  
  reg_tok = regexp(d(kk).name, '(?:lasso_run_)(.*)(?:\.mat)', 'tokens');
  feature_set_names{kk} = reg_tok{1}{1};
  
  load(fullfile(lasso_run_dir, d(kk).name), 'lasso_runs');

  this_feature_idx = find(strcmp(sort_order, feature_set_names{kk}));
  
  for jj = 1:length(lasso_runs)
    if lasso_runs(jj).AUC < 0.6 || strcmp(lasso_runs(jj).YPositiveClassLabel, 'RCB<2.5')
      % Performance too low for this response/feature set; also skip RCB<2.5 category
      continue;
    end
    
    lasso_run = remove_extra_birads_nonmass(lasso_runs(jj));
    
    PlotCoefficients(lasso_run, 'b_response_in_title', false);
    replace_captions;
    
    response_name = sanitize_struct_fieldname(lasso_run.YName);
    output_filename = sprintf('raw_features_%s_%02d_%s', response_name, this_feature_idx, feature_set_names{kk});
    
    paper_print(output_filename, 15, 2, output_dir);
  end
end

function replace_captions
% Change some feature names

h = findobj(gcf, 'tag', 'features');

ylabels = get(h, 'yticklabel');
ylabels = strrep(ylabels, 'TNM_N_', 'TNM:');
ylabels = strrep(ylabels, 'stage_ia_iiia_', 'Tumor Stage');
ylabels = strrep(ylabels, '_result_', '');
ylabels = strrep(ylabels, 'clinical ', '');
ylabels = strrep(ylabels, 'cycles_of_treatment_received_', 'Treatment Cycles: ');
ylabels = strrep(ylabels, ' (all possible cycles)', '');
ylabels = strrep(ylabels, 'brca', 'BRCA');
ylabels = strrep(ylabels, 'ki67', 'Ki67');
ylabels = strrep(ylabels, 'age_at_diagnosis', 'Age');
ylabels = strrep(ylabels, 'ki67', 'Ki67');
ylabels = strrep(ylabels, 'tumor_grade_', 'Tumor Grade');
ylabels = strrep(ylabels, 'Chemotherapy', 'chemo');
ylabels = regexprep(ylabels, '(BI-RADS) Mass.*None', '$1 Non-Mass');
ylabels = strrep(ylabels, 'Non-Mass Internal', 'Non-Mass');
ylabels = strrep(ylabels, 'Enhancement Homogeneous', 'Enhancement Homog.');
ylabels = strrep(ylabels, 'Distribution Modifiers Segmental', 'Segmental');
ylabels = strrep(ylabels, 'Area Under Contrast Curve', 'Contrast AUC');



ylabels = strrep(ylabels, '_', ' ');

set(h, 'yticklabel', ylabels);

function lasso_run = remove_extra_birads_nonmass(lasso_run)
% TODO
1;