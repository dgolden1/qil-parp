function [px_x, px_y] = mm_to_px(im_mm_x, im_mm_y, mm_x, mm_y)
% Convert coordinates in mm to pixels
% [px_x, px_y] = mm_to_px(im_mm_x, im_mm_y, mm_x, mm_y)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: mm_to_px.m 124 2012-12-11 23:43:40Z dgolden $

px_x = convert_one_dim(im_mm_x, mm_x);
px_y = convert_one_dim(im_mm_y, mm_y);

function coord_px = convert_one_dim(im_mm, coord_mm)
% Node that im_mm may be increasing OR decreasing

coords_norm = (coord_mm - im_mm(1))/diff(im_mm([1 end])); % Coordinates between 0 and 1
coord_px = coords_norm*(length(im_mm) - 1) + 1;

1;
