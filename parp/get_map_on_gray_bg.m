function [img, cax_param, img_original] = get_map_on_gray_bg(bg_img, roi_mask, kinetic_param, varargin)
% Get a jet lesion map on the gray subtraction image background
% [img, cax_param, img_original] = get_map_on_gray_bg(bg_img, roi_mask, kinetic_param, cax_param)

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('cax_param', quantile(kinetic_param(:), [0.01 0.99]));
p.addParamValue('cax_bg', quantile(bg_img(roi_mask), [0.01 0.99]));
p.addParamValue('colormap', jet(64));
p.parse(varargin{:});

cax_param = p.Results.cax_param;
cax_bg = p.Results.cax_bg;

%% The grayscale subtraction image background

img_original = ind2rgb(gray2ind(mat2gray(bg_img, cax_bg)), gray(64));

%% Overlay kinetic parameter
colors_param = ind2rgb(gray2ind(mat2gray(kinetic_param, cax_param), size(p.Results.colormap, 1)), p.Results.colormap);
img = img_original;
img(repmat(roi_mask, [1 1 3])) = colors_param;

1;
