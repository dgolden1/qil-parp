function obj = ResizeImage(obj, scale_factor, varargin)
% Resize image and ROI
% obj = ResizeImage(obj, scale_factor, varargin)
% 
% PARAMETERS
% imresize_method: any method that you can pass to the imresize() function, e.g., 'box',
%  'lanczos2', 'lanczos3' (default), etc.
% min_value: minimum value allowed in output image (default: -Inf). E.g., if image is a
%  ratio, min_value should be 0; if it's a CT image, min_value should be -1000. This
%  is important because ringing in the lanczos kernel may cause the minimum value of the
%  image to get lower

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: ResizeImage.m 329 2013-07-05 19:03:46Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('imresize_method', 'lanczos3');
p.addParamValue('min_value', -Inf)
p.parse(varargin{:});

%% Determine whether image is NaN outside ROI
% Some images are NaN outside the ROI because only the within-ROI pixels were determined
% (e.g., vie to PK modeling). The imresize function doesn't deal with NaNs properly, so
% to deal with this, assign the NaN values to be nearest-neighbor interpolations of the
% non-NaN values, then resize, then set them back to NaN
% 
% Wow, this is a great idea - why didn't I think of it earlier??

fraction_nan_outside_roi = sum(isnan(obj.Image(~obj.MyROI.ROIMask)))/sum(~obj.MyROI.ROIMask(:));
if fraction_nan_outside_roi > 0.95
  b_nan_outside_roi = true;
else
  b_nan_outside_roi = false;
end

%% Deal with NaN values
old_image = obj.Image;
nan_idx = isnan(old_image);
[row, col] = ndgrid(1:size(old_image, 1), 1:size(old_image, 2));
T = TriScatteredInterp(col(~nan_idx), row(~nan_idx), old_image(~nan_idx), 'nearest');
old_image(nan_idx) = T(col(nan_idx), row(nan_idx));
% old_image(isnan(old_image)) = nanval;

%% Resize image
[new_image, new_x_coords, new_y_coords] = resize_image_and_coords(old_image, obj.SpatialXCoords, obj.SpatialYCoords, scale_factor, 'imresize_method', p.Results.imresize_method);
obj.Image = new_image;
obj.SpatialXCoords = new_x_coords;
obj.SpatialYCoords = new_y_coords;

%% Resize ROI
obj.MyROI = Resize(obj.MyROI, scale_factor, new_x_coords, new_y_coords);

%% Reassign NaN values
if b_nan_outside_roi
  obj.Image(~obj.MyROI.ROIMask) = nan;
end

%% Set min value
obj.Image(obj.Image < p.Results.min_value) = p.Results.min_value;

1;