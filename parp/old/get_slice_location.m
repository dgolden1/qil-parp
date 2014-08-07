function slice_location = get_slice_location(info)
% Get slice locations which have the same values as the X locations for
% sagittal slices, or the Z locations for axial slices

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

% Make sure info is a row vector
old_dims = size(info);
info = info(:).';

% I thought there was a bug in my previous method of determining slice
% location, but in retrospect, it seems fine
% for kk = 1:length(info)
%   [x_mm, y_mm, z_mm, slice_plane] = get_dicom_xyz(info(kk));
% 
%   switch slice_plane
%     case 'axial'
%       slice_location(kk,1) = z_mm;
%     case 'sagittal'
%       slice_location(kk,1) = x_mm;
%     otherwise
%       error('Coronal images are not supported');
%   end
% end

image_positions = [info.ImagePositionPatient];
image_orientations = [info.ImageOrientationPatient];

if all(image_positions(1,1) == image_positions(1,:)) && ...
    all(image_positions(2,1) == image_positions(2,:)) 
  % The X and Y values of the origin of each image is the same; images are
  % in the axial plane and must vary in the Z direction
  slice_location = image_positions(3,:);
elseif all(image_positions(2,1) == image_positions(2,:)) && ...
    all(image_positions(3,1) == image_positions(3,:))
  % The Y and Z values of the origin of each image is the same; images are
  % in the sagittal plane and must vary in the X direction
  slice_location = image_positions(1,:);
else
  error('Coronal images are not supported');
end

slice_location = reshape(slice_location, old_dims);
