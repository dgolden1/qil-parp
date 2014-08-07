function plot_model_features
% Plot scatter plots for each feature vs. RCB value

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
close all;

plot_output_dir = '~/temp';
b_save_plot = false;

b_show_patient_ids = false;

load('lesion_parameters.mat', 'lesions');

%% Remove outliers
lesions = exclude_patients(lesions);

%% Parse some stuff from the lesions struct
fn = fieldnames(lesions);
rcb_val = [lesions.rcb_val];
patient_ids = [lesions.patient_id];

%% Plot distribution of RCBs

% Value (real number)
figure;
edges = 0:0.5:(max([lesions.rcb_val])+0.5);
n = histc(rcb_val, edges);
bar(edges(1:end-1) + diff(edges)/2, n(1:end-1), 1);
grid on;
yl = ylim;
% set(gca, 'xtick', min([lesions.rcb_score]):max([lesions.rcb_score]), 'ytick', yl(1):yl(end));
xlabel('RCB Value');
ylabel('Count');
increase_font;

if b_save_plot
  this_filename = fullfile(plot_output_dir, 'rcb_distribution.png');
  print('-dpng', '-r90', this_filename);
  fprintf('Saved %s\n', this_filename);
end


%% Lesion averaged parameters
% super_subplot parameters
nrows = 3;
ncols = 3;
hspace = 0.075;
vspace = 0.05;
hmargin = [0.075 0.025];
vmargin = [0.1 0.025];

avg_param_names = {'avg_ktrans', ...
                   'avg_kep', ...
                   'avg_ve', ...
                   'avg_wash_in', ...
                   'avg_wash_out', ...
                   'avg_auc', ...
                   'patient_age', ...
                   'lesion_area', ...
                   'num_regions'};
                   

figure;
set(gcf, 'Name', 'Averaged parameters');
for kk = 1:length(avg_param_names)
  this_param_name = avg_param_names{kk};
  this_param_val = [lesions.(this_param_name)];
  
  % subplot(3, 3, kk);
  super_subplot(nrows, ncols, kk, hspace, vspace, hmargin, vmargin);
  plot_one_feature(rcb_val, this_param_val, this_param_name, patient_ids, b_show_patient_ids);
  
  if kk >= 7
    xlabel('RCB Value');
  else
    set(gca, 'xticklabel', '');
  end
end
figure_grow(gcf, 1.5);
increase_font;
set(findobj(gcf, 'tag', 'patient_id_label'), 'fontsize', 12);

if b_save_plot
  this_filename = fullfile(plot_output_dir, 'lesion_avg_params.png');
  print('-dpng', '-r90', this_filename);
  fprintf('Saved %s\n', this_filename);
end

%% Gray-level co-occurrence matrix parameters
% super_subplot parameters
nrows = 3;
ncols = 4;

glcm_names = fieldnames(lesions);
glcm_names(cellfun(@isempty, strfind(glcm_names, 'glcm'))) = [];

%% GLCM PK
figure;
set(gcf, 'Name', 'GLCM PK Texture');
for kk = 1:12
  this_param_val = [lesions.(glcm_names{kk})];
  this_param_name = strrep(glcm_names{kk}, 'glcm_', '');
  
  % subplot(3, 4, kk);
  super_subplot(nrows, ncols, kk, hspace, vspace, hmargin, vmargin);
  plot_one_feature(rcb_val, this_param_val, this_param_name, patient_ids, b_show_patient_ids);
  
  if kk >= 9
    xlabel('RCB Value');
  else
    set(gca, 'xticklabel', '');
  end
end

figure_grow(gcf, 2.25, 1.5);
increase_font;
set(findobj(gcf, 'tag', 'patient_id_label'), 'fontsize', 12);

if b_save_plot
  this_filename = fullfile(plot_output_dir, 'lesion_texture_pk.png');
  print('-dpng', '-r90', this_filename);
  fprintf('Saved %s\n', this_filename);
end

%% GLCM Empirical
figure;
set(gcf, 'Name', 'GLCM Empirical Texture');
for kk = 1:12
  this_param_val = [lesions.(glcm_names{kk+12})];
  this_param_name = strrep(glcm_names{kk+12}, 'glcm_', '');
  
  % subplot(3, 4, kk);
  super_subplot(nrows, ncols, kk, hspace, vspace, hmargin, vmargin);
  plot_one_feature(rcb_val, this_param_val, this_param_name, patient_ids, b_show_patient_ids);
  
  if kk >= 9
    xlabel('RCB Value');
  else
    set(gca, 'xticklabel', '');
  end
end

figure_grow(gcf, 2.25, 1.5);
increase_font;
set(findobj(gcf, 'tag', 'patient_id_label'), 'fontsize', 12);

if b_save_plot
  this_filename = fullfile(plot_output_dir, 'lesion_texture_empirical.png');
  print('-dpng', '-r90', this_filename);
  fprintf('Saved %s\n', this_filename);
end

function plot_one_feature(rcb_val, feature_val, feature_name, patient_ids, b_show_patient_ids)
%% Function: Make a single scatter plot of one feature

str_pre_or_post = 'pre';
b_is_stanford_patient = is_stanford_scan(patient_ids, str_pre_or_post);

feature_name_clean = replace_strings(feature_name, ...
  {{'_', ' '}, {'correlation', 'corr'}, {'homogeneity', 'homog'}, ...
  {'area under curve', 'AUC'}, {'auc', 'AUC'}, {' slope', ''}});

if any(b_is_stanford_patient)
  plot(rcb_val(b_is_stanford_patient), feature_val(b_is_stanford_patient), 'o', 'markeredgecolor', 'r', 'markerfacecolor', 'r');
  hold on
end
if any(~b_is_stanford_patient)
  plot(rcb_val(~b_is_stanford_patient), feature_val(~b_is_stanford_patient), 'o', 'markeredgecolor', 'b', 'markerfacecolor', 'b');
end

grid on;
% ylabel(feature_name_clean);
set(gca, 'xtick', 0:4);

plot_title = sprintf('%s\nr = %0.2f', feature_name_clean, nancorr(rcb_val(:), feature_val(:)));
xl = xlim;
yl = ylim;
h = text(xl(1) + diff(xl)/2, yl(1) + diff(yl)*0.8, plot_title, 'horizontalalignment', 'center');

% Don't let Matlab change the axis limits, since the plot title is tied to
% specific values
set(gca, 'xlimmode', 'manual', 'ylimmode', 'manual');

% title(plot_title);

if b_show_patient_ids
  label_scatter_pts(rcb_val, feature_val, patient_ids);
end

function str = replace_strings(str, replacements)
%% Function: Replace a bunch of substrings at once

for kk = 1:length(replacements)
  str = strrep(str, replacements{kk}{1}, replacements{kk}{2});
end
