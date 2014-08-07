function [dicom_x, dicom_y, dicom_z] = GetDICOMCoords(img_x, img_y, img_slice_coord, img_slice_plane)
% Get DICOM coordinates from image coordinates (static method)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

switch img_slice_plane
  case 'saggital'
    dicom_y = img_x;
    dicom_z = img_y;
    dicom_x = img_slice_coord;
  case 'coronal'
    dicom_z = img_x;
    dicom_x = img_y;
    dicom_y = img_slice_coord;
  case 'axial'
    dicom_x = img_x;
    dicom_y = img_y;
    dicom_z = img_slice_coord;
  otherwise
    error('Invalid value for img_slice_plane');
end
