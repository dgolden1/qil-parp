function [IF2D, z_spatial] = GetImageFeature2D(obj, varargin)
% Get a single slice as a 2D ImageFeature object
% 
% PARAMETERS
% z_pixel
% z_spatial
% b_split_multiple_rois

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('z_pixel', []);
p.addParamValue('z_spatial', []); % Z coordinates in SpatialCoordUnits (e.g., mm)
p.addParamValue('b_split_multiple_rois', false); % If a slice has multiple ROIs, split into multiple image features
p.parse(varargin{:});

%% If Z-coord is not given, choose slice with biggest ROI with no NaNs
if isempty(p.Results.z_pixel) && isempty(p.Results.z_spatial)
  roi_areas = zeros(length(obj.MyROI3D.ROIs), 1);
  for kk = 1:length(obj.MyROI3D.ROIs)
    roi_areas(kk) = sum(obj.MyROI3D.ROIs(kk).ROIMask(:));
  end

  [~, sort_idx] = sort(roi_areas, 'descend'); % Sort with biggest first

  IF2D = [];
  for kk = 1:length(sort_idx)
    this_slice_idx = obj.MyROI3D.ROIZValues(sort_idx(kk));
    this_image_feature = GetImageFeature2D(obj, 'z_pixel', this_slice_idx); % Recursion

    % Might get multiple 2D ROIs in this image feature; find the one with the largest area
    this_roi_areas = cellfun(@(x) sum(x.ROIMask(:)), num2cell(this_image_feature.MyROI));
    [~, biggest_area_idx] = max(this_roi_areas);
    this_image_feature.MyROI = this_image_feature.MyROI(biggest_area_idx);

    % Ensure that ROI doesn't contain NaNs
    if any(isnan(GetROIPixels(this_image_feature)))
      continue;
    else
      IF2D = this_image_feature;
      z_spatial = obj.MyROI3D.ImageZmm(obj.MyROI3D.ROIZValues(sort_idx(kk)));
      break;
    end
  end

  if isempty(IF2D)
    error('Unable to find suitable slice');
  end
  
  if p.Results.b_split_multiple_rois
    IF2D = split_by_rois(IF2D);
  end
  
  return;
end

%% Get slice
if ~isempty(p.Results.z_spatial)
  z_spatial = p.Results.z_spatial;
  slice_idx = interp1(obj.SpatialZCoords, 1:length(obj.SpatialZCoords), p.Results.z_spatial, 'nearest');
elseif ~isempty(p.Results.z_pixel)
  z_spatial = interp1(1:length(obj.SpatialZCoords), obj.SpatialZCoords, p.Results.z_pixel, 'nearest');
  slice_idx = p.Results.z_pixel;
end

img = obj.ImageVolume(:,:,slice_idx);

if isempty(obj.MyROI3D)
  roi_2d = ROI.empty;
else
  roi_2d = obj.MyROI3D.ROIs(obj.MyROI3D.ROIZValues == slice_idx); % Might have 0, 1, or more ROIs
end

%% Create image feature
IF2D = ImageFeature(img, 'ImageName', obj.ImageName, 'ID', obj.PatientID, 'ImagePrettyName', obj.ImagePrettyName, ...
  'MyROI', roi_2d, 'SpatialXCoords', obj.SpatialXCoords, 'SpatialYCoords', obj.SpatialYCoords, ...
  'SpatialCoordUnits', obj.SpatialCoordUnits);

if p.Results.b_split_multiple_rois
  IF2D = split_by_rois(IF2D);
end

function image_features_out = split_by_rois(image_feature_in)
%% Function: split an image feature into multiple ones if multiple ROIs

if isempty(image_feature_in.MyROI)
  image_features_out = ImageFeature.empty;
end

for kk = 1:length(image_feature_in.MyROI)
  image_features_out(kk) = image_feature_in;
  image_features_out(kk).MyROI = image_feature_in.MyROI(kk);
end
