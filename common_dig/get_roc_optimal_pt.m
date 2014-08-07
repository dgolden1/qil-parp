function [x_opt, y_opt] = get_roc_optimal_pt(x, y)
% Get ROC optimal point as the point on the ROC curve that minimizes the distance to the
% upper left corner (0,1)

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: get_roc_optimal_pt.m 152 2013-01-23 00:48:44Z dgolden $

dist_to_corner = sqrt(x.^2 + (1 - y).^2);
[~, optimal_pt_idx] = min(dist_to_corner);
x_opt = x(optimal_pt_idx);
y_opt = y(optimal_pt_idx);