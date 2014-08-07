function [x_center, y_center, max_dim_x, max_dim_y] = GetCenter(obj)
% Get x and y coordinates (in pixels) of ROI center
% [x, y, max_dim_x, max_dim_y] = GetCenter(obj)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id: GetCenter.m 231 2013-04-01 21:50:18Z dgolden $


%% Get center
roi_mask = obj.ROIMask;
roi_x_lim = [find(any(roi_mask, 1), 1, 'first'), find(any(roi_mask, 1), 1, 'last')];
roi_y_lim = [find(any(roi_mask, 2), 1, 'first'), find(any(roi_mask, 2), 1, 'last')];

if isempty(roi_x_lim)
  x_center = nan;
  y_center = nan;
  max_dim_x = 0;
  max_dim_y = 0;
  return;
end

roi_center = [roi_x_lim(1) + diff(roi_x_lim)/2, roi_y_lim(1) + diff(roi_y_lim)/2];
x_center_px = roi_center(1);
y_center_px = roi_center(2);

max_dim_x_px = diff(roi_x_lim);
max_dim_y_px = diff(roi_y_lim);

%% Convert to mm or not
if obj.bPlotInmm
  [x_center, y_center] = px_to_mm(obj.ImageXmm, obj.ImageYmm, x_center_px, y_center_px);
  max_dim_x = max_dim_x_px*abs(diff(obj.ImageXmm(1:2)));
  max_dim_y = max_dim_y_px*abs(diff(obj.ImageYmm(1:2)));
else
  x_center = x_center_px;
  y_center = y_center_px;
  max_dim_x = max_dim_x_px;
  max_dim_y = max_dim_y_px;
end

