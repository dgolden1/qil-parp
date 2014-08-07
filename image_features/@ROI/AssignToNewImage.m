function obj = AssignToNewImage(obj, image_x_mm_new, image_y_mm_new)
% Assign ROI to a new image in the same mm coordinate system with possibly different
% dimensions

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id: AssignToNewImage.m 185 2013-02-13 01:42:05Z dgolden $

image_x_mm_old = obj.ImageXmm;
image_y_mm_old = obj.ImageYmm;

[poly_x_mm, poly_y_mm] = px_to_mm(image_x_mm_old, image_y_mm_old, obj.ROIPolyX, obj.ROIPolyY);
[poly_x_px_new, poly_y_px_new] = mm_to_px(image_x_mm_new, image_y_mm_new, poly_x_mm, poly_y_mm);

obj.ROIPolyX = poly_x_px_new;
obj.ROIPolyY = poly_y_px_new;
obj.ImageXmm = image_x_mm_new;
obj.ImageYmm = image_y_mm_new;
