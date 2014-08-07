function [mm_x, mm_y] = px_to_mm(im_mm_x, im_mm_y, px_x, px_y)
% Convert coordinates in pixels to mm
% [mm_x, mm_y] = px_to_mm(im_mm_x, im_mm_y, px_x, px_y)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: px_to_mm.m 186 2013-02-13 18:59:39Z dgolden $

mm_x = interp1(1:length(im_mm_x), im_mm_x, px_x, 'linear', 'extrap');
mm_y = interp1(1:length(im_mm_y), im_mm_y, px_y, 'linear', 'extrap');
