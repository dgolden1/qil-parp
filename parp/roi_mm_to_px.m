function [x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm, y_coord_mm, roi_x_mm, roi_y_mm)
% Convert coordinates in mm to coordinates in image pixels, e.g., to use
% for the poly2mask function which requires coordinates in image pixels
% when calculating the ROI mask

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

x_roi_px = interp1(x_coord_mm, 1:length(x_coord_mm), roi_x_mm);
y_roi_px = interp1(y_coord_mm, 1:length(y_coord_mm), roi_y_mm);
