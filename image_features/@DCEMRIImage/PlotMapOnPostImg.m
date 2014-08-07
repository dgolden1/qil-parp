function cax_param = PlotMapOnPostImg(obj, IF_name, varargin)
% Plot a jet-colored kinetic map on a gray-colored post-contrast image
% PlotMapOnPostImg(obj, IF_name, varargin)

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
addpath(fullfile(danmatlabroot, 'parp')) % For get_map_on_gray_bg()

%% Parse input arguments
p = inputParser;
p.addParamValue('b_colorbar', false);
p.addParamValue('b_length_marker', true);
p.addParamValue('cax', []);
p.addParamValue('colormap', jet(64));
p.addParamValue('h_ax', []); % Axis on which to plot
p.parse(varargin{:});

if isempty(p.Results.h_ax)
  figure;
else
  saxes(p.Results.h_ax);
end

%% Generate image
bg_img = obj.IFPostContrast.Image;
roi_mask = obj.MyROI.ROIMask;
IF = obj.(IF_name);
kinetic_param = IF.Image(roi_mask);

if isempty(p.Results.cax)
  cax_param = quantile(kinetic_param(:), [0.01 0.99]);
else
  cax_param = p.Results.cax;
end
[img, cax_param, img_original] = get_map_on_gray_bg(bg_img, roi_mask, kinetic_param, 'cax_param', cax_param, 'colormap', p.Results.colormap);

%% Plot
image(img);
h_ax = gca;
axis equal off;
title(sprintf('Patient %s %s', obj.PatientIDStr, IF.ImagePrettyName));

PlotZoomToROI(obj.MyROI);

if p.Results.b_length_marker
  PlotDrawLengthMarker(obj.MyROI, 'line_color', 'r');
end

if p.Results.b_colorbar
  cbar_width = 0.025;
  
  pos = get(gca, 'position');
  %set(gca, 'position', [pos(1:2), pos(3) - cbar_width, pos(4)]);
  c = axes('position', [pos(1) + pos(3) - cbar_width, pos(2), cbar_width, pos(4)]);
  imagesc(0, linspace(0, 1, size(p.Results.colormap, 1))*diff(cax_param) + min(cax_param), permute(p.Results.colormap, [1 3 2]));
  set(c, 'xtick', [], 'yaxislocation', 'right');
  axis xy;
end

saxes(h_ax);
increase_font;
