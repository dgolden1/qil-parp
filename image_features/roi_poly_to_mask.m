function roi_mask = roi_poly_to_mask(roi_poly_x, roi_poly_y, im_size)
% Convert ROI poly to ROI mask

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: roi_poly_to_mask.m 124 2012-12-11 23:43:40Z dgolden $


roi_mask = poly2mask(roi_poly_x, roi_poly_y, im_size(1), im_size(2));
