function zoom_to_lesion(x_coord_mm, y_coord_mm, roi_mask, color)
% Zoom to lesion when plotting an image
% zoom_to_lesion(x_coord_mm, y_coord_mm, roi_mask, color)

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
if ~exist('color', 'var') || isempty(color)
  color = 'r';
end

%% Zoom
[X, Y] = meshgrid(x_coord_mm, y_coord_mm);
lesion_x_lim = [min(X(roi_mask)) max(X(roi_mask))];
lesion_y_lim = [min(Y(roi_mask)) max(Y(roi_mask))];
max_dim = max([diff(lesion_x_lim), diff(lesion_y_lim)]);
lesion_center = [min(X(roi_mask)) + diff(lesion_x_lim)/2, min(Y(roi_mask)) + diff(lesion_y_lim)/2];
axis([lesion_center(1) + [-1 1]*0.7*max_dim, lesion_center(2) + [-1 1]*0.7*max_dim]);
xl = xlim;
yl = ylim;

%% Make 1 cm marker for reference
if ~strcmp(color, 'none')
  hold on;

  line_y_val = yl(1) + 0.1*diff(yl);
  plot(lesion_center(1) + [-5 5], line_y_val*[1 1], '-', 'color', color, 'linewidth', 2);
  text(lesion_center(1), line_y_val, '1 cm', ...
    'color', color, 'horizontalalignment', 'center', 'verticalalignment', 'top', 'fontweight', 'bold');
end
