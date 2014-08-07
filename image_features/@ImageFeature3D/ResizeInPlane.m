function obj = ResizeInPlane(obj, scale_factor, varargin)
% Resize all slices of the 3D ImageFeature
% obj = ResizeInPlane(obj, scale_factor, 'param', value, ...)
% 
% This resizing occurs in the IN-PLANE dimension only; the slice thickness remains
% constant
% 
% If there are NaNs in the volume, the resizing won't work properly; there will be lots
% more NaNs in the output (this function doesn't deal with NaNs cleverly like in
% ImageFeature.ResizeImage)
% 
% PARAMETERS
% imresize_method: any method that you can pass to the imresize() function, e.g., 'box',
%  'lanczos2', 'lanczos3' (default), etc.
% min_value: minimum value allowed in output image (default: -Inf). E.g., if image is a
%  ratio, min_value should be 0; if it's a CT image, min_value should be -1000. This
%  is important because ringing in the lanczos kernel may cause the minimum value of the
%  image to get lower


% By Daniel Golden (dgolden1 at stanford dot edu) May 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('imresize_method', 'lanczos3');
p.addParamValue('min_value', -Inf)
p.parse(varargin{:});

%% Resize the image volume
%new_image_volume = nan([size(imresize(zeros(size(obj.ImageVolume(:,:))), scale_factor)), size(obj.ImageVolume, 3)]);

% Resize the first slice and use its dimensions to pre-allocate a new image volume
[new_first_slice, x_coords_resized, y_coords_resized] = resize_image_and_coords(obj.ImageVolume(:,:,1), obj.SpatialXCoords, obj.SpatialYCoords, scale_factor, 'imresize_method', 'lanczos2');
new_image_volume = nan([size(new_first_slice), size(obj.ImageVolume, 3)]);

for kk = 2:size(obj.ImageVolume, 3)
  new_image_volume(:,:,kk) = imresize(obj.ImageVolume(:,:,kk), scale_factor, p.Results.imresize_method);
end

%% Set min value
new_image_volume(new_image_volume < p.Results.min_value) = p.Results.min_value;

%% Resize the ROIs
for kk = 1:length(obj.MyROI3D.ROIs)
  new_rois_2d(kk) = Resize(obj.MyROI3D.ROIs(kk), scale_factor, x_coords_resized, y_coords_resized);
end
new_roi_3d = ROI3D(new_rois_2d, obj.MyROI3D.ROIZValues, obj.MyROI3D.ImageZmm);

%% Create new ImageFeature3D object
new_obj = ImageFeature3D(new_image_volume, obj.ImageName, obj.PatientID, 'roi_3d', new_roi_3d, ...
  'spatial_x_coords', x_coords_resized, 'spatial_y_coords', y_coords_resized, 'spatial_z_coords', obj.SpatialZCoords, ...
  'spatial_coord_units', obj.SpatialCoordUnits);

obj = new_obj;
