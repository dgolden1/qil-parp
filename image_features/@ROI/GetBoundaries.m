function [xl, yl] = GetBoundaries(obj)
% Get ROI boundaries (in pixels)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: GetBoundaries.m 244 2013-04-18 00:07:53Z dgolden $

[x_center, y_center, max_dim_x, max_dim_y] = GetCenter(obj);
xl = x_center + max_dim_x*[-1 1]/2;
yl = y_center + max_dim_y*[-1 1]/2;
