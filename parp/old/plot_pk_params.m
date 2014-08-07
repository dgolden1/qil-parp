function plot_pk_params(x_coord_mm, y_coord_mm, x_label, y_label, bg_img, roi_mask, ktrans, kep, ve, varargin)
% Plot pharmacokinetic parameters determined with Nick's code
% plot_pk_params(x_coord_mm, y_coord_mm, bg_img, roi_mask, ktrans, kep, ve, varargin)
% 
% PARAMETERS
% bg_img_name: name for the title of the bg_img (default: '')
% max_ve: upper caxis limit on ve (default: unbounded)
% b_zoom: if false (default), displays entire image; if true, zooms in to
%  lesion
% h_fig: figure handle on which to plot (default: opens a new figure)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
p = inputParser;
p.addParamValue('bg_img_name', '');
p.addParamValue('max_ve', inf);
p.addParamValue('b_zoom', false);
p.addParamValue('h_fig', []);
p.parse(varargin{:});
bg_img_name = p.Results.bg_img_name;
max_ve = p.Results.max_ve;
b_zoom = p.Results.b_zoom;
h_fig = p.Results.h_fig;

if size(bg_img, 3) ~= 1
  error('bg_img must be an NxM matrix');
end

%% Create images
% cax_quant = [0.01 0.99]; % Clip the color axis at these quantiles
% 
% % Original image, grayscale
% img_difference = slices(:,:,end) - slices(:,:,1);
% img_original = ind2rgb(gray2ind(mat2gray(img_difference, quantile(img_difference(roi_mask), cax_quant))), gray(64));
% 
% % Overlay PK parameters as colors on top of images
% cax_ktrans = quantile(ktrans, cax_quant);
% cax_kep = quantile(kep, cax_quant);
% cax_ve = quantile(ve, cax_quant);
% colors_ktrans = ind2rgb(gray2ind(mat2gray(ktrans, cax_ktrans)), jet(64));
% colors_kep = ind2rgb(gray2ind(mat2gray(kep, cax_kep)), jet(64));
% colors_ve = ind2rgb(gray2ind(mat2gray(ve, cax_ve)), jet(64));
% 
% img_ktrans = img_original;
% img_kep = img_original;
% img_ve = img_original;
% 
% img_ktrans(repmat(roi_mask, [1 1 3])) = colors_ktrans;
% img_kep(repmat(roi_mask, [1 1 3])) = colors_kep;
% img_ve(repmat(roi_mask, [1 1 3])) = colors_ve;

[img_ktrans, cax_ktrans, img_original] = get_map_on_gray_bg(bg_img, roi_mask, ktrans);
[img_kep, cax_kep] = get_map_on_gray_bg(bg_img, roi_mask, kep);
% [img_ve, cax_ve] = get_map_on_gray_bg(bg_img, roi_mask, ve);
[img_ve, cax_ve] = get_map_on_gray_bg(bg_img, roi_mask, ve, [0, min(quantile(ve, 0.99), max_ve)]);

%% Plot
% super_subplot parameters
nrows = 2;
ncols = 2;
hspace = 0.075;
vspace = 0.075;
hmargin = [0.15 0.05];
vmargin = [0.1 0.1];

tickdir = 'in';

if isempty(h_fig);
  figure;
else
  sfigure(h_fig);
  clf;
end

s(1) = super_subplot(nrows, ncols, 1, hspace, vspace, hmargin, vmargin);
image(x_coord_mm, y_coord_mm, img_original);
axis xy equal tight;
ylabel(y_label);
set(gca, 'xticklabel', [], 'tickdir', tickdir);
title(bg_img_name);

s(2) = super_subplot(nrows, ncols, 2, hspace, vspace, hmargin, vmargin);
image(x_coord_mm, y_coord_mm, img_ktrans);
axis xy equal tight;
set(gca, 'xticklabel', [], 'yticklabel', [], 'tickdir', tickdir, 'tag', 'im_ktrans');
title('K^{trans} (min^{-1})');
plot_colorbar(s(2), cax_ktrans);

s(3) = super_subplot(nrows, ncols, 3, hspace, vspace, hmargin, vmargin);
image(x_coord_mm, y_coord_mm, img_kep);
axis xy equal tight;
set(gca, 'tickdir', tickdir, 'tag', 'im_kep');
title('K_{ep} (min^{-1})');
xlabel(x_label);
ylabel(y_label);
plot_colorbar(s(3), cax_kep);

s(4) = super_subplot(nrows, ncols, 4, hspace, vspace, hmargin, vmargin);
image(x_coord_mm, y_coord_mm, img_ve);
axis xy equal tight;
set(gca, 'tickdir', tickdir, 'tag', 'im_ve');
set(gca, 'yticklabel', []);
title('v_{e} (unitless)');
xlabel(x_label);
plot_colorbar(s(4), cax_ve);

linkaxes(s);

if b_zoom
  saxes(s(1));
  zoom_to_lesion(x_coord_mm, y_coord_mm, roi_mask, 'r');
end

zoom on;
figure_grow(gcf, 1, 1.4);
increase_font

1;

function h_cbar = plot_colorbar(img_ax, cax)
%% Function: plot colorbar

pos = get(img_ax, 'position');
cax_pos = [pos(1) + 0.9*pos(3), pos(2) + 0.02, 0.1*pos(3), pos(4) - 0.04];
h_cbar(1) = axes('position', cax_pos, 'yaxislocation', 'right');
h_cbar(2) = log_colorbar(cax, 'h_cbar', h_cbar, 'b_log', false);
1;
