function get_image_val(m, xlab, ylab)
% Use ginput to select a point on an image; print the x and y labels and the matrix
% value
% 
% It is assumed that the user has already plotted the image and that it's the active
% axis

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id: get_image_val.m 303 2013-06-18 00:31:05Z dgolden $

[x, y] = ginput(1);
x = round(x);
y = round(y);
fprintf('%s <--> %s: %G\n', xlab{x}, ylab{y}, m(y,x));