function obj = SetImgCoords(obj)
% Sets image coordinates based on DICOM coordinates

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

if isscalar(obj.DICOMCoordsmm.x) % Saggital slices
  obj.XCoordmm = obj.DICOMCoordsmm.y;
  obj.YCoordmm = obj.DICOMCoordsmm.z;
  obj.SliceCoordmm = obj.DICOMCoordsmm.x;
  obj.XLabel = 'Y (mm)';
  obj.YLabel = 'Z (mm)';
  obj.SliceLabel = 'X (mm)';
  obj.SlicePlane = 'saggital';
elseif isscalar(obj.DICOMCoordsmm.y) % Coronal slices
  obj.XCoordmm = obj.DICOMCoordsmm.z;
  obj.YCoordmm = obj.DICOMCoordsmm.x;
  obj.SliceCoordmm = obj.DICOMCoordsmm.y;
  obj.XLabel = 'Z (mm)';
  obj.YLabel = 'X (mm)';
  obj.SliceLabel = 'Y (mm)';
  obj.SlicePlane = 'coronal';
elseif isscalar(obj.DICOMCoordsmm.z) % Axial slices
  obj.XCoordmm = obj.DICOMCoordsmm.x;
  obj.YCoordmm = obj.DICOMCoordsmm.y;
  obj.SliceCoordmm = obj.DICOMCoordsmm.z;
  obj.XLabel = 'X (mm)';
  obj.YLabel = 'Y (mm)';
  obj.SliceLabel = 'Z (mm)';
  obj.SlicePlane = 'axial';
else
  error('One of x_mm, y_mm or z_mm should be a scalar');
end
