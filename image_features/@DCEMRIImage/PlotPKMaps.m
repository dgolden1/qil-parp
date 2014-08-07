function PlotPKMaps(obj, varargin)
% Plot pharmacokinetic parameters determined with Nick's code
% plot_pk_params(x_coord_mm, y_coord_mm, bg_img, roi_mask, ktrans, kep, ve, varargin)
% 
% PARAMETERS
% max_ve: upper caxis limit on ve (default: unbounded)
% h_fig: figure handle on which to plot (default: opens a new figure)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
p = inputParser;
p.addParamValue('max_ve', inf);
p.addParamValue('h_fig', []);
p.parse(varargin{:});
max_ve = p.Results.max_ve;
h_fig = p.Results.h_fig;

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
PlotImage(obj.IFPostContrast, 'colormap', 'gray', 'b_zoom_to_roi', true, 'b_length_marker', true, 'h_ax', s(1));
title(sprintf('PARP %s Post-Contrast', patient_id_tostr(obj.PatientID)));

s(2) = super_subplot(nrows, ncols, 2, hspace, vspace, hmargin, vmargin);
PlotMapOnPostImg(obj, 'IFKtrans', 'b_length_marker', false, 'b_colorbar', true, 'h_ax', s(2));
title('K^{trans} (min^{-1})');
%plot_colorbar(s(2), cax_ktrans);

s(3) = super_subplot(nrows, ncols, 3, hspace, vspace, hmargin, vmargin);
PlotMapOnPostImg(obj, 'IFKep', 'b_length_marker', false, 'b_colorbar', true, 'h_ax', s(3));
title('K_{ep} (min^{-1})');
%plot_colorbar(s(3), cax_kep);

s(4) = super_subplot(nrows, ncols, 4, hspace, vspace, hmargin, vmargin);
if isinf(p.Results.max_ve)
  cax = [];
else
  cax = [quantile(obj.IFVe.Image(:), 0.01), p.Results.max_ve];
end
PlotMapOnPostImg(obj, 'IFVe', 'cax', cax, 'b_length_marker', false, 'b_colorbar', true, 'h_ax', s(4));
title('v_{e} (unitless)');
%plot_colorbar(s(4), cax_ve);

linkaxes(s);

zoom on;
increase_font

if isempty(h_fig)
  figure_grow(gcf, 1, 1.4);
end

1;

function h_cbar = plot_colorbar(img_ax, cax)
%% Function: plot colorbar

pos = get(img_ax, 'position');
cax_pos = [pos(1) + 0.9*pos(3), pos(2) + 0.02, 0.1*pos(3), pos(4) - 0.04];
h_cbar(1) = axes('position', cax_pos, 'yaxislocation', 'right');
h_cbar(2) = log_colorbar(cax, 'h_cbar', h_cbar, 'b_log', false);
1;
