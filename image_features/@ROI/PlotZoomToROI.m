function PlotZoomToROI(obj, zoom_out_factor)
% Zoom to lesion in a plot of the image and ROI (coordinates are in pixels)
%
% zoom_out_factor: how much larger than the ROI should the field of view be?
%  Bigger numbers are more zoomed out. If zoom_out_factor is 2, for example, the
%  lesion will occupy half the image (by length)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id: PlotZoomToROI.m 261 2013-05-08 04:17:16Z dgolden $

if ~exist('zoom_out_factor', 'var') || isempty(zoom_out_factor)
  zoom_out_factor = 1.5;
end

if sum(obj.ROIMask(:)) == 0
  warning('Unable to zoom to ROI; ROI mask is empty');
  return;
end

[x_center, y_center, max_dim_x, max_dim_y] = GetCenter(obj);

max_dim = max(max_dim_x, max_dim_y);
xl = x_center + [-1 1]*zoom_out_factor/2*max(max_dim);
yl = y_center + [-1 1]*zoom_out_factor/2*max(max_dim);
axis([xl yl]);
