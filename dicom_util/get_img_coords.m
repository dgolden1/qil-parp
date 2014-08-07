function [x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label, plane_name] = get_img_coords(x_mm, y_mm, z_mm)
% Gets image coordinates from DICOM coordinates
% 
% [x_coord_mm, y_coord_mm, x_label, y_label, slice_location_mm, slice_label] = get_img_coords(x_mm, y_mm, z_mm)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

if isscalar(x_mm) % Saggital slices
  x_coord_mm = y_mm;
  y_coord_mm = z_mm;
  slice_location_mm = x_mm;
  x_label = 'Y (mm)';
  y_label = 'Z (mm)';
  slice_label = 'X (mm)';
  plane_name = 'saggital';
elseif isscalar(y_mm) % Coronal slices
  x_coord_mm = z_mm;
  y_coord_mm = x_mm;
  slice_location_mm = y_mm;
  x_label = 'Z (mm)';
  y_label = 'X (mm)';
  slice_label = 'Y (mm)';
  plane_name = 'coronal';
elseif isscalar(z_mm) % Axial slices
  x_coord_mm = x_mm;
  y_coord_mm = y_mm;
  slice_location_mm = z_mm;
  x_label = 'X (mm)';
  y_label = 'Y (mm)';
  slice_label = 'Z (mm)';
  plane_name = 'axial';
else
  error('One of x_mm, y_mm or z_mm should be a scalar');
end
