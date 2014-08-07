function BatchPlotGLCMs(obj, output_dir)
% Plot GLCMs via ImageFeature.PlotGLCM function

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Setup
close all;
output_dir = fullfile(obj.Dirname, 'glcm_images');
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end
cmd = sprintf('rm -rf %s%s*', output_dir, filesep);
system(cmd);
fprintf('%s\n', cmd);

h_fig = figure;
figure_grow(gcf, 1.5, 1);

%% Loop over patients
BatchFun(obj, @(x) plot_and_save_from_one_image(x, h_fig, output_dir));

function plot_and_save_from_one_image(dce_mri_image, h_fig, output_dir)
%% Function: plot and save a single GLCM figure

image_features = {'IFKtrans', 'IFKep', 'IFVe', 'IFWashIn', 'IFWashOut', 'IFAUC'};

for kk = 1:length(image_features)
  clf(h_fig);
  this_image_feature = dce_mri_image.(image_features{kk});
  PlotGLCM(this_image_feature, 'h_fig', h_fig);
  increase_font;
  
  output_filename = fullfile(output_dir, sprintf('%s_glcm_%s.png', image_features{kk}(3:end), ...
    patient_id_tostr(dce_mri_image.PatientID)));
  
  print_trim_png(output_filename);
  fprintf('Saved %s\n', output_filename);
end
