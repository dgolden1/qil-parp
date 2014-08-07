function obj = ConvertFromSpline(obj)
% Convert an ROI that had previously been converted to a spline via ROI.ConvertToSpline
% back to a polygon

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: ConvertFromSpline.m 185 2013-02-13 01:42:05Z dgolden $

if ~obj.bIsSpline
  error('ROI has not been converted to spline');
end

obj.ROIPolyX = obj.ROINonSplinePolyX;
obj.ROIPolyY = obj.ROINonSplinePolyY;

obj.ROINonSplinePolyX = [];
obj.ROINonSplinePolyY = [];
