function h_rect = plot_rectangle(h_ax, x, y)
% Plot a red rectangle on an image

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

saxes(h_ax);
hold on;

x_pts = [min(x) min(x) max(x) max(x) min(x)];
y_pts = [min(y) max(y) max(y) min(y) min(y)];

h_rect = plot(x_pts, y_pts, 'r-', 'linewidth', 2);
