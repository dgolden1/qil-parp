function varargout = plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, varargin)
% Function to map the DCE-MRI parameters for a slice
% 
% rgb_img = plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'param', value, ...)
% 
% INPUTS
% slices: an NxMxR matrix of NxM slices of DCE-MRI values, once for each
%  of R time points
% x_mm, y_mm and z_mm: the DICOM coordinates for each slice (mm)
% t: the time of each slice in sec
% info: the DICOM header for each slice
% 
% PARAMETERS
% param_type: either 'empirical' (default) to color lightness by wash-in slope
%  and color by wash-out slope.  Eventually, this function may support 'pk'
%  to create a cell array of three maps for ktrans, kep and ve,
%  respectively
% roi_poly: include the roi_poly struct from the get_lesion_roi.m function
%  to plot the roi overlaid on the image
% roi_mask: include the roi_mask struct from the get_lesion_roi.m function
%  to set the color scale with respect to the lesion wash in and wash out,
%  or to zoom to the lesion
% contrast_mask: if provided, the 1th and 99th percentiles of the pixels
%  within contrast_mask will be used to determine the colorbar limits
% h_ax: make the image on the given axes
% b_color_only_lesion: if true (default) kinetic parameters are only
%  determined within the ROI mask; otherwise, kinetic parameters are determined
%  for the entire image
% b_colorbar: if true (default) include a colorbar for wash-out hue
% b_zoom: set to true to zoom into the lesion, if the roi_poly is provided
%  (default: false)
% b_plot: true to make a plot, false to just return the image.  If this
%  parameters is not given, then a plot will be created if the caller
%  requests no output
% 
% OUTPUT
% rgb_img: either an NxMx3 RGB image (empirical parameters) or a structure
% of three such NxM images corresponding to values of ktrans, kep and ve,
% respectively

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('param_type', 'empirical');
p.addParamValue('roi_poly', []);
p.addParamValue('roi_mask', []);
p.addParamValue('contrast_mask', []);
p.addParamValue('h_ax', []);
p.addParamValue('b_color_only_lesion', []);
p.addParamValue('b_colorbar', true);
p.addParamValue('b_zoom', false);
p.addParamValue('b_plot', []);
p.parse(varargin{:});
param_type = p.Results.param_type;
roi_poly = p.Results.roi_poly;
roi_mask = p.Results.roi_mask;
contrast_mask = p.Results.contrast_mask;
h_ax = p.Results.h_ax;
b_color_only_lesion = p.Results.b_color_only_lesion;
b_colorbar = p.Results.b_colorbar;
b_zoom = p.Results.b_zoom;
b_plot = p.Results.b_plot;

if isempty(b_plot) && nargout == 0
  b_plot = true;
elseif isempty(b_plot)
  b_plot = false;
end

if b_zoom && isempty(roi_mask)
  error('To zoom to lesion, roi_mask must be entered as a parameter');
end

if isempty(b_color_only_lesion) && isempty(roi_mask)
  b_color_only_lesion = false;
elseif isempty(b_color_only_lesion) && ~isempty(roi_mask)
  b_color_only_lesion = true;
elseif b_color_only_lesion && isempty(roi_mask)
  error('To color only lesion, roi_mask must be entered as a parameter');
end

if isempty(contrast_mask) && ~isempty(roi_mask)
  if b_color_only_lesion
    % Empirical parameters determined only for some pixels
    contrast_mask = true(1, sum(roi_mask(:)));
  else
    contrast_mask = roi_mask;
  end
end

%% Get curve empirical criteria
% Criteria determined by Hauth et al., 2008, 10.1016/j.ejrad.2007.05.026

[x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label] = get_img_coords(x_mm, y_mm, z_mm);

if b_color_only_lesion
  slices_mask = reshape(slices(repmat(roi_mask, [1, 1, size(slices, 3)])), sum(roi_mask(:)), size(slices, 3));
  [wash_in_slope, wash_out_slope, ~, ~, time_points] = get_empirical_params(slices_mask, info, t);
else
  [wash_in_slope, wash_out_slope, ~, ~, time_points] = get_empirical_params(slices, info, t);
end

if isempty(contrast_mask)
  contrast_mask = true(size(wash_in_slope));
end


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

rgb_pixels = max(min(hsv2rgb([H(:) S(:) V(:)]), 1), 0);
if ~b_color_only_lesion
  rgb_img = reshape(rgb_pixels, size(wash_in_slope, 1), size(wash_in_slope, 2), 3);
else
  post_slice = slices(:,:,find(t > 60, 1, 'first'));
  rgb_img = ind2rgb(gray2ind(mat2gray(post_slice, quantile(post_slice(roi_mask), [0.01 0.99]))), gray(64));
  rgb_img(mask_2d_nd(rgb_img, roi_mask)) = rgb_pixels;
end



%% Plot RGB image
% Only plot if user requested no output arguments
if nargout > 0
  varargout{1} = rgb_img;
end
if ~b_plot
  return;
end

if isempty(h_ax)
  figure;
  if b_colorbar
    h_ax_img(1) = subplot(1, 4, 1:3);
  else
    h_ax_img = gca;
  end
else
  saxes(h_ax);
  cla;
end
  
image(x_coord_mm, y_coord_mm, rgb_img);
axis equal tight xy;
xlabel(x_label);
ylabel(y_label);
title('Emprical kinetic map');
set(gca, 'tag', 'im_mapped');
zoom on;

% Colorbar
if isempty(h_ax) && b_colorbar
  h_ax_img(2) = subplot(1, 4, 4);
  cmap = hsv2rgb(cmap_hsv);
  clim = [min_slope2 max_slope2]; % Contrast units/msec -> Contrast units/min
  c = image(1, linspace(clim(1), clim(2), 64), permute(cmap, [1 3 2]));
  axis xy;
  set(gca, 'xtick', [], 'yaxislocation', 'right');
  ylabel(gca, 'Wash out slope (contrast units/min)');

  saxes(h_ax_img(1));
end

%% Overlay the ROI
if ~isempty(roi_poly)
  hold on;
  plot(roi_poly.img_x_mm([1:end, 1]), roi_poly.img_y_mm([1:end, 1]), 'wo-');
end

if isempty(h_ax)
  increase_font;
end

%% Zoom to lesion
if b_zoom && ~isempty(roi_mask)
  zoom_to_lesion(x_coord_mm, y_coord_mm, roi_mask, 'w');
end

1;
