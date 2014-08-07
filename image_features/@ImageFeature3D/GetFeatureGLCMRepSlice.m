function [feature_set, glcm, selected_image_feature, z_mm] = GetFeatureGLCMRepSlice(obj, varargin)
% Get GLCM features on a representative slice in the middle of the lesion
% 
% PARAMETERS
% b_tighten_roi: tighten ROI for lung CT (default: false)
% tightening_thresh: pixel value threshold for ROI tightening (default: -400)
% plot_output_dir: set to something to make a plot of the representative slices
% b_tighten_first: true to tighten first, then get ImageFeature; false (default) to get
%  ImageFeature and then tighten it
% z_spatial: Optionally, specify a specific z value (in spatial coordinates, e.g., mm)
%  for the slice to use; otherwise, the default slice is used via
%  ImageFeature3D.GetImageFeature2D.
% h_fig: figure handle to plot on if plot_output_dir is true
% 
% remaining parameters are passed to ImageFeature.GetFeatureGLCM

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$


%% Parse input arguments
p = inputParser;
p.addParamValue('b_tighten_roi', false);
p.addParamValue('tightening_thresh', -400);
p.addParamValue('plot_output_dir', ''); 
p.addParamValue('b_tighten_first', true);
p.addParamValue('z_spatial', []);
p.addParamValue('h_fig', []);
[args_in, args_out] = arg_subset(varargin, p.Parameters);
p.parse(args_in{:});

%% Tighten ROI (before ImageFeature extraction)
if p.Results.b_tighten_roi && p.Results.b_tighten_first
  obj = TightenLungCTROI(obj, 'tightening_thresh', p.Results.tightening_thresh);
end

%% Get 2D ImageFeature object
% Find the slice with the biggest ROI that doesn't contain all NaNs

[selected_image_feature, z_mm] = GetImageFeature2D(obj, 'z_spatial', p.Results.z_spatial);

%% Tighten ROI (after ImageFeature extraction)
if p.Results.b_tighten_roi && ~p.Results.b_tighten_first
  this_slice_idx = interp1(obj.MyROI3D.ImageZmm, 1:length(obj.MyROI3D.ImageZmm), z_mm, 'nearest');
  
  mask_3d_tight = GetTightenedLungMask(obj, 'tightening_thresh', p.Results.tightening_thresh);
  mask_2d_tight = mask_3d_tight(:,:,this_slice_idx);
  selected_image_feature.MyROI = selected_image_feature.MyROI.SetMask(mask_2d_tight, 'method', 'bwboundaries');
end

%% Get GLCM feature
% Set ImageName to blank to not include it in the GLCM feature names
selected_image_feature.ImageName = '';
selected_image_feature.ImagePrettyName = '';

[feature_set, glcm] = GetFeatureGLCM(selected_image_feature, args_out{:});

%% Plot
if ~isempty(p.Results.plot_output_dir)
  if ~isempty(p.Results.h_fig)
    sfigure(p.Results.h_fig);
  else
    figure;
    figure_grow(gcf, 2, 1);
  end
  
  clf;
  s(1) = subplot(1, 3, 1);
  s(2) = subplot(1, 3, 2);
  s(3) = subplot(1, 3, 3);

  % Change colors to resemble those that make up GLCM by quantizing
  img = selected_image_feature.Image;
  glcm_cax = quantile(GetROIPixels(selected_image_feature), p.Results.quantiles);
  bin_width = diff(glcm_cax)/p.Results.numlevels;
  bin_centers = (glcm_cax(1) + bin_width*0.5):bin_width:(glcm_cax(2) - bin_width*0.5);
  bin_edges = glcm_cax(1):bin_width:glcm_cax(2);
  lut_in = bin_centers;
  lut_out = 1:8;
  img_quantized = interp1(lut_in, lut_out, img, 'nearest', 'extrap');
  
%   img(img < glcm_cax(1)) = glcm_cax(1);
%   img(img > glcm_cax(2)) = glcm_cax(2);
%   img = ((img - min(img(:)))/(max(img(:)) - min(img(:)))*p.Results.numlevels*0.999) + 0.5; % Scale to be between 0.5 and 8.5
%   img = round(img);
  
  % Assign quantized image to new ImageFeature object
  image_feature_for_plotting = selected_image_feature;
  image_feature_for_plotting.Image = img_quantized;
  
  % Plot non-quantized image
%   PlotImage(selected_image_feature, 'h_ax', s(1));
%   c = colorbar;
%   ylabel(c, 'HU');
  
  % Plot quantized image
  PlotImage(image_feature_for_plotting, 'h_ax', s(1));
  c = colorbar;
  ylabel(c, 'Quantized Value');
  
  % Plot ECDF
  saxes(s(2));
  [f,x] = ecdf(GetROIPixels(selected_image_feature));
  [~, idx_unique] = unique(x);
  stairs(x, f, 'linewidth', 2);
  hold on;
  plot(bin_edges, interp1(x(idx_unique), f(idx_unique), bin_edges), 'ko', 'markerfacecolor', 'g', 'markersize', 8); % Plot bin edges
  plot(glcm_cax, interp1(x(idx_unique), f(idx_unique), glcm_cax), 'ko', 'markerfacecolor', 'r', 'markersize', 10); % Plot quantiles
  grid on;
  xlim([-400 400]);
  title('Empirical CDF');
  xlabel('HU');
  ylabel('Probability');
  
  % Plot GLCM
  saxes(s(3));
  imagesc(sum(glcm, 3));
  axis equal tight
  colorbar;
  title(sprintf('GLCM (contrast = %0.2f)', feature_set.GetValuesByFeature('glcm_contrast')));
  
  increase_font;
  
  output_filename = fullfile(p.Results.plot_output_dir, sprintf('glcm_slice_contrast_%03.0f_id_%s.png', GetValuesByFeature(feature_set, 'glcm_contrast')*100, obj.PatientID));
  print_trim_png(output_filename);
  fprintf('Saved %s\n', output_filename);
end

1;
