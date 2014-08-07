function roi_2d = GetROI2DAtZ(obj, z, str_px_or_mm)
% Get a 2D ROI at a given Z location
% roi_2d = GetROI2DAtZ(obj, z, str_px_or_mm)
% str_px_or_mm should be either 'mm' if z is given in mm, or 'px' if z is given in
%  pixels

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

if strcmp(str_px_or_mm, 'mm')
  % Convert from mm to pixels
  z_px = interp1(obj.ImageZmm, 1:length(obj.ImageZmm), z, 'nearest');
else
  z_px = z;
end

nearest_roi_idx = interp1(obj.ROIZValues, 1:length(obj.ROIZValues), z_px, 'nearest', 'extrap');
if ~ismember(z_px, obj.ROIZValues)
  error('No ROI at z index %d (%0.1f mm); nearest ROI is at index %d (%0.1f mm)', ...
    z_px, obj.ImageZmm(z_px), nearest_roi_idx, obj.ImageZmm(obj.ROIZValues(nearest_roi_idx)));
end

roi_2d = obj.ROIs(nearest_roi_idx);
