function value = GetROIMask(obj)
% Get 3D volumetric ROI mask

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

mask_3d = false(length(obj.ImageY), length(obj.ImageX), length(obj.ImageZmm));

for kk = 1:length(obj.ROIs)
  % Assign the 2D mask from this 2D ROI to the appropriate slice of the 3D mask
  mask_2d = obj.ROIs(kk).ROIMask;
  mask_3d(:,:,obj.ROIZValues(kk)) = mask_3d(:,:,obj.ROIZValues(kk)) | mask_2d;
end

value = mask_3d;
