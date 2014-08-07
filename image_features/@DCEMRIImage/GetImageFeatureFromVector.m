function IF = GetImageFeatureFromVector(obj, values, name, pretty_name)
% Make an image feature object from a vector of masked pixels

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~isvector(values)
  error('GetImageFeatureFromVector is only for a vector of masked pixels');
end
if length(values) ~= sum(obj.MyROI.ROIMask(:))
  error('Length mismatch between image pixels and sum of ROIMask');
end

img = nan(obj.Size2D);
img(obj.MyROI.ROIMask) = values;
IF = ImageFeature(img, 'ImageName', name, 'ID', obj.PatientID, 'ImagePrettyName', pretty_name, ...
  'MyROI', obj.MyROI, 'SpatialXCoords', obj.XCoordmm, ...
  'SpatialYCoords', obj.YCoordmm, 'SpatialCoordUnits', 'mm');
