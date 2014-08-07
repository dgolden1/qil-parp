function obj = CropToROI(obj)
% Crop an ImageFeature object to its ROI

% By Daniel Golden (dgolden1 at stanford dot edu) April 2013
% $Id: CropToROI.m 276 2013-05-24 18:44:49Z dgolden $

% Calculate cropped dimensions (in pixels)
[xl, yl] = GetBoundaries(obj.MyROI);
xl = [floor(xl(1)), ceil(xl(2))];
yl = [floor(yl(1)), ceil(yl(2))];

%% Crop image
obj.Image = obj.Image(yl(1):yl(2), xl(1):xl(2));
obj.SpatialXCoords = obj.SpatialXCoords(xl(1):xl(2));
obj.SpatialYCoords = obj.SpatialYCoords(yl(1):yl(2));

%% Crop ROI
image_x_mm = obj.MyROI.ImageXmm(xl(1):xl(2));
image_y_mm = obj.MyROI.ImageYmm(yl(1):yl(2));

if ~isempty(obj.MyROI.ROIPolyX)
  roi_poly_x = obj.MyROI.ROIPolyX - xl(1) + 1;
  roi_poly_y = obj.MyROI.ROIPolyY - yl(1) + 1;
  obj.MyROI = ROI(roi_poly_x, roi_poly_y, image_x_mm, image_y_mm);
else
  roi_mask = obj.MyROI.ROIMask(yl(1):yl(2), xl(1):xl(2));
  obj.MyROI = ROI([], [], image_x_mm, image_y_mm, 'ROIMask', roi_mask);
end