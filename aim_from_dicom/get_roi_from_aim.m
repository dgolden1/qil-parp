function [x, y, image_reference_UID] = get_roi_from_aim(aim_filename, b_always_cell_output)
% Get ROI from AIM DOM object
% [x, y, sopInstanceUID] = get_roi_from_aim(aim_filename)
% 
% If there is only one ROI in the AIM file, x and y will be vectors;
% otherwise, they will be cell arrays of vectors
%
% if b_always_cell_output is true, x and y will always be cell arrays of
% vectors, even if there is only one ROI
% 
% See Oracle org.w3c.dom package information for function reference:
% http://docs.oracle.com/javase/6/docs/api/org/w3c/dom/package-summary.html
% 
% NOTE: x,y coordinates are IMAGE PIXEL coordinates, NOT DICOM coordinates
% x and y are whatever the X and Y axes are when you call imagesc(img) in
% Matlab

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
if ~exist('b_always_cell_output', 'var') || isempty(b_always_cell_output)
  % Always return x and y as cell arrays, even if there's only one
  % geometric shape?
  b_always_cell_output = false;
end

%% Load AIM file
aim_xdom = xmlread(aim_filename);

%% Get AIM image UID
imageList = aim_xdom.getElementsByTagName('Image');
if imageList.getLength ~= 1
  error('Wanted 1 Image tag, found %d', imageList.getLength);
end
thisImage = imageList.item(0);

sopClassUID = thisImage.getAttribute('sopClassUID');
sopInstanceUID = thisImage.getAttribute('sopInstanceUID');

%% Find GeometricShape(s)
geometricShapeList = aim_xdom.getElementsByTagName('GeometricShape');
num_geometric_shapes = geometricShapeList.getLength;

for kk = 1:num_geometric_shapes
  thisGeometricShape = geometricShapeList.item(kk-1);
  [x{kk}, y{kk}, image_reference_UID{kk}] = get_one_geometric_shape(thisGeometricShape);
end

if length(x) == 1 && ~b_always_cell_output
  x = x{1};
  y = y{1};
end


function [x, y, image_reference_UID] = get_one_geometric_shape(geometric_shape)
%% Function: get coordinates of a single geometric shape
% Geometric shape must be a spatial coordinate collection


thisShapeType = geometric_shape.getAttribute('xsi:type');
if ~strcmp(thisShapeType, 'Polyline')
  error('Geometric shape type ''%s'' not implemented', thisShapeType);
end

%% Find spatialCoordinateCollection
spatialCoordinateCollectionsList = geometric_shape.getElementsByTagName('spatialCoordinateCollection');
if spatialCoordinateCollectionsList.getLength ~= 1
  error('Only able to handle one spatialCoordinateCollection (%d found)', spatialCoordinateCollectionsList.getLength);
end

thisSpatialCoordinateCollection = spatialCoordinateCollectionsList.item(0);
spatialCoordinateList = thisSpatialCoordinateCollection.getElementsByTagName('SpatialCoordinate');

% Loop over spatial coordinates
for kk = 0:spatialCoordinateList.getLength-1
  thisSpatialCoordinate = spatialCoordinateList.item(kk);
  
  % Some error checking
  thisSpatialCoordinateImageReferenceUID = thisSpatialCoordinate.getAttribute('imageReferenceUID');
  if kk == 0
    firstSpatialCoordinateImageReferenceUID = thisSpatialCoordinateImageReferenceUID;
  elseif ~strcmp(thisSpatialCoordinateImageReferenceUID, firstSpatialCoordinateImageReferenceUID)
    error('This spatial coordinate imageReferenceUID (%s) does not match the first coordinate''s imageReferenceUID (%s)', ...
      char(thisSpatialCoordinateImageReferenceUID), char(firstSpatialCoordinateImageReferenceUID));
  end
  
  % if ~strcmp(sopInstanceUID, thisSpatialCoordinateImageReferenceUID)
  %   error('This spatial coordinate imageReferenceUID (%s) does not match master image sopInstanceUID (%s)', ...
  %     char(thisSpatialCoordinateImageReferenceUID), char(sopInstanceUID));
  % end
  
  if ~strcmp(thisSpatialCoordinate.getAttribute('xsi:type'), 'TwoDimensionSpatialCoordinate')
    error('Only xsi:type supported is TwoDimensionSpatialCoordinate; this xsi:type is %s', char(thisSpatialCoordinate.getAttribute('xsi:type')));
  end
  
  % Coordinates are in general not in order; the "index" attribute
  % specifies the order. I think this is dumb, but whatever, maybe there's
  % a good reason.
  %
  % Add 0.5 to x and y values because AIM coordinates from OsiriX iPAD are apparently
  % 0.5-indexed and Matlab image coordinates are 1-indexed
  roi.x(kk+1) = str2double(thisSpatialCoordinate.getAttribute('x')) + 0.5;
  roi.y(kk+1) = str2double(thisSpatialCoordinate.getAttribute('y')) + 0.5;
  roi.idx(kk+1) = str2double(thisSpatialCoordinate.getAttribute('coordinateIndex'));
end

% Sort the coordinates by "coordinateIndex" attribute
[~, idx_sort] = sort(roi.idx);
x = roi.x(idx_sort);
y = roi.y(idx_sort);

image_reference_UID = char(firstSpatialCoordinateImageReferenceUID);

% Some junk I decided not to do:
% geometricShapeCollection = aim_xdom.getElementsByTagName('geometricShapeCollection');
% 
% % Make sure there's only one geometricShapeCollection
% assert(geometricShapeCollection.getLength == 1);
% 
% geometricShapeList = geometricShapeCollection.item(0);
% geometricShapeListChildren = geometricShapeList.getChildNodes;

1;
