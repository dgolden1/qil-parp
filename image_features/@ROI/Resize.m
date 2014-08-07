function obj = Resize(obj, scale_factor, new_x_coords, new_y_coords)
% Resize the ROI to match a resized image

% By Daniel Golden (dgolden1 at stanford dot edu) May 2013
% $Id: Resize.m 276 2013-05-24 18:44:49Z dgolden $

if isempty(obj.ROIPolyX)
  % Resize the mask
  obj = ROI([], [], new_x_coords, new_y_coords, 'ROIMask', imresize(obj.ROIMask, scale_factor));
else
  % Otherwise, make a new ROI with the new polygon
  new_roi_poly_x = (obj.ROIPolyX - 1)*scale_factor + 1;
  new_roi_poly_y = (obj.ROIPolyY - 1)*scale_factor + 1;
  obj = ROI(new_roi_poly_x, new_roi_poly_y, new_x_coords, new_y_coords);
end
