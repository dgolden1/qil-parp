function PlotEmpiricalMapHSV(obj, varargin)
% Plot the empirical map using wash-in as value and wash-out as hue
% plot_empirical_kinetic_map(obj, 'param', value, ...)
% 
% PARAMETERS
% contrast_mask: if provided, the 1th and 99th percentiles of the pixels
%  within contrast_mask will be used to determine the colorbar limits
% h_ax: make the image on the given axes
% b_color_only_lesion: if true (default) kinetic parameters are only
%  colored within the ROI mask; otherwise, kinetic parameters are colored
% b_colorbar: if true (default) include a colorbar for wash-out hue
% b_zoom: set to true to zoom into the lesion, if the roi_poly is provided
%  (default: false)
% 

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Error check
if isempty(obj.IFWashIn)
  error('Must run CreateEmpiricalMaps() before plotting empirical maps');
end

%% Parse input arguments
p = inputParser;
p.addParamValue('contrast_mask', []);
p.addParamValue('h_ax', []);
p.addParamValue('b_roi', true);
p.addParamValue('b_color_only_lesion', false);
p.addParamValue('b_colorbar', true);
p.addParamValue('b_zoom', true);
p.parse(varargin{:});
contrast_mask = p.Results.contrast_mask;
h_ax = p.Results.h_ax;
b_roi = p.Results.b_roi;
b_color_only_lesion = p.Results.b_color_only_lesion;
b_colorbar = p.Results.b_colorbar;
b_zoom = p.Results.b_zoom;

if b_zoom && isempty(obj.MyROI)
  error('To zoom to lesion, ROI must be determined');
end

if b_color_only_lesion && isempty(obj.MyROI)
  error('To color only lesion, ROI must be determined');
end

if isempty(obj.MyROI)
  roi_mask = [];
else
  roi_mask = obj.MyROI.ROIMask; % May be empty if ROI has not been determined
end

% Set contrast_mask to ROI if contrast_mask is not given and ROI exists;
% otherwise, set it to the entire image
if isempty(contrast_mask) && ~isempty(obj.MyROI)
  if b_color_only_lesion
    contrast_mask = roi_mask;
  else
    contrast_mask = true(obj.Size2D);
  end
elseif isempty(contrast_mask)
  contrast_mask = true(obj.Size2D);
end

%% Get empirical maps

wash_in_slope = obj.IFWashIn.Image;
wash_out_slope = obj.IFWashOut.Image;

%% Create RGB image

% HSV color
% Hue: initial slope
% Saturation (0=gray, 1=color): initial value
% Value (0=dark, 1=bright): wash-out slope
cmap_hsv = rgb2hsv(jet(64));
cmap_hsv(:,2:3) = 1;
cmap_hsv = flipud(unique(cmap_hsv, 'rows'));

% min_slope2 = min(wash_out_slope(idx_noheart)); % Set min/max by visible range
% max_slope2 = max(wash_out_slope(idx_noheart));

% max_slope2 = 500;
% min_slope2 = -500; % Set min/max by hard limits (contrast units/min)

max_slope1 = quantile(flatten(wash_in_slope(contrast_mask)), 0.99);
min_slope1 = quantile(flatten(wash_in_slope(contrast_mask)), 0.01);

% Set min/max by quantiles not centered at 0
% max_slope2 = quantile(flatten(wash_out_slope(:)), 0.99);
% min_slope2 = quantile(flatten(wash_out_slope(:)), 0.01);

% Set min/max by quantiles centered at 0
max_slope2 = max(abs(quantile(flatten(wash_out_slope(contrast_mask)), [0.01 0.99])));
min_slope2 = -max_slope2;


V = (wash_in_slope - min_slope1)/(max_slope1 - min_slope1);
V = max(min(V, 1), 0); % Clip out-of-range values

% S = (ampl1 - min(ampl1(idx_noheart)))/(max(ampl1(idx_noheart)) - min(ampl1(idx_noheart)));
% S = (ampl2 - min(ampl2(idx_noheart)))/(max(ampl2(idx_noheart)) - min(ampl2(idx_noheart)));
S = ones(size(wash_in_slope));

H_idx = (wash_out_slope - min_slope2)/(max_slope2 - min_slope2);
H = interp1(linspace(0, 1, size(cmap_hsv, 1)), cmap_hsv(:,1), H_idx, 'linear', 'extrap');
H(H < min(cmap_hsv(:,1))) = min(cmap_hsv(:,1)); % Clip out-of-range values
H(H > max(cmap_hsv(:,1))) = max(cmap_hsv(:,1));

rgb_pixels = reshape(max(min(hsv2rgb([H(:) S(:) V(:)]), 1), 0), [obj.Size2D, 3]);
if b_color_only_lesion
  post_slice = obj.IFPostContrast.Image;
  rgb_img = ind2rgb(gray2ind(mat2gray(post_slice, quantile(post_slice(roi_mask), [0.01 0.99]))), gray(64));
  roi_mask_3d = mask_2d_nd(rgb_img, roi_mask);
  rgb_img(roi_mask_3d) = rgb_pixels(roi_mask_3d);
else
  rgb_img = rgb_pixels;
end


%% Plot RGB image
if isempty(h_ax)
  figure;
else
  saxes(h_ax);
  cla;
end
  
if b_colorbar && isempty(h_ax)
  h_ax_img(1) = subplot(1, 6, 1:5);
else
  h_ax_img = gca;
end

image(rgb_img);
axis equal tight off;
title(sprintf('Patient %s Emprical kinetic map', obj.PatientIDStr));
set(gca, 'tag', 'im_mapped');
zoom on;

% Colorbar
if b_colorbar && isempty(h_ax)
  h_ax_img(2) = subplot(1, 6, 6);
  cmap = hsv2rgb(cmap_hsv);
  clim = [min_slope2 max_slope2]; % Contrast units/msec -> Contrast units/min
  c = image(1, linspace(clim(1), clim(2), 64), permute(cmap, [1 3 2]));
  axis xy;
  set(gca, 'xtick', [], 'yaxislocation', 'right');
  ylabel(gca, 'Wash out slope (contrast units/min)');

  saxes(h_ax_img(1));
end

%% Do stuff with the ROI
if b_roi
  hold on;
  PlotROI(obj.MyROI, 'roi_color', 'w', 'b_zoom_to_roi', b_zoom);
end

% Increase font
if isempty(h_ax)
  increase_font;
end

1;
