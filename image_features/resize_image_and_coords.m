function [img_resized, im_x_resized, im_y_resized] = resize_image_and_coords(img, im_x, im_y, scale_factor, varargin)
% Resize an image and its coordinate axes
% [img_resized, im_x_resized, im_y_resized] = resize_image_and_coords(img, im_x, im_y, scale_factor, varargin)
% 
% We shift the coordinate endpoints slightly, assuming that they still represent the
% middle of the pixels
% 
% INPUTS
% img: original image
% im_x, im_y: vector of original image x and y axes (e.g., plot(im_x, im_y,
%  img); these are in SPATIAL units (e.g., mm), not pixels (unless your
%  coordinates are pixels)
% scale_factor: scale factor when resizing (shrink the image to half size -->
%  scale_factor = 0.5)
% 
% PARAMETERS
% imresize_method: the method used for imresize interpolation; does not apply to
%  coordinate rescaling, which is always linearly interpolated
% 
% OUTPUTS
% img_resized: resized image
% im_x_resized, im_y_resized: x and y axes in the new image coordinate system

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: resize_image_and_coords.m 278 2013-05-24 23:27:43Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('imresize_method', 'lanczos3');
p.parse(varargin{:});

%% Resize image
img_resized = imresize(img, scale_factor, p.Results.imresize_method);

%% Resize coordinates
spatial_res = abs(diff(im_x(1:2)));

% How much to shift the axes endpoints by to keep the coordinates in the middle of the
% original pixel locations
end_shift_amt = (1/scale_factor - 1)/2*spatial_res;

b_decending_x = diff(im_x([1 end])) < 0;
new_ends_x = [im_x(1), im_x(end)] + [1 -1]*end_shift_amt*(-1)^b_decending_x;

b_decending_y = diff(im_y([1 end])) < 0;
new_ends_y = [im_y(1), im_y(end)] + [1 -1]*end_shift_amt*(-1)^b_decending_y;

im_x_resized = linspace(new_ends_x(1), new_ends_x(2), size(img_resized, 2));
im_y_resized = linspace(new_ends_y(1), new_ends_y(2), size(img_resized, 1));

