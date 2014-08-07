function [img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(img_vals, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_constrain_output)
% Resize image and ROI together so ROI is still valid
% [img_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(img_vals, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_constrain_output)
% 
% if b_constrain_output is true, values of the output image less than a
% threshold will be set to nan and excluded from the ROI, and image areas
% outside the ROI will be set to NaN (useful if the image is only defined
% within the ROI, such as for a PK map)
% 
% This function is similar to, but more specific than, resize_image_and_coords.m

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012

%% Setup
if ~exist('b_constrain_output', 'var') || isempty(b_constrain_output)
  b_constrain_output = false;
end

%% Resize image
% This is the (relatively) easy part
if isvector(img_vals)
  img_original = zeros(size(roi_mask));
  img_original(roi_mask) = img_vals;
else
  img_original = img_vals;
end
img_resized = imresize(img_original, scale_factor, 'lanczos3');

%% Recalculate coordinates
% Keep image size (in mm) the same
y_coord_mm_resized = linspace(y_coord_mm(1), y_coord_mm(end), size(img_resized, 1));
x_coord_mm_resized = linspace(x_coord_mm(1), x_coord_mm(end), size(img_resized, 2));

%% Recalculate ROI
[x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm_resized, y_coord_mm_resized, roi_poly.img_x_mm, roi_poly.img_y_mm);
roi_mask_resized = poly2mask(x_roi_px, y_roi_px, size(img_resized, 1), size(img_resized, 2));

%% Get rid of invalid values in resized image
if b_constrain_output
  idx_valid = roi_mask_resized & img_resized > 0.01; % Lanczos-3 kernel can make some pixel values less than 0
  roi_mask_resized(~idx_valid) = false;
  img_resized(~roi_mask_resized) = nan;
end

%% If input was a vector, return a vector
if isvector(img_vals)
  img_resized = img_resized(roi_mask_resized);
end
