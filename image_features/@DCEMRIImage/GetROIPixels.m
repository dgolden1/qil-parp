function roi_pixels = GetROIPixels(obj)
% Get pixels in ROI
% Output is an NxM vector of N ROI pixels in M time points

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

roi_mask_2d = obj.MyROI.ROIMask;
roi_mask_3d = repmat(roi_mask_2d, [1, 1, length(obj.Time)]);

roi_pixels_vec = obj.ImageStack(roi_mask_3d);
roi_pixels = reshape(roi_pixels_vec, [sum(roi_mask_2d(:)), length(obj.Time)]);
