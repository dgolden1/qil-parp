function roi_conv_hull = CombineROIs(varargin)
% Combine multiple ROIs by taking their convex hull

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: CombineROIs.m 185 2013-02-13 01:42:05Z dgolden $

if ~all(cellfun(@(x) isa(x, 'ROI'), varargin))
  error('Input arguments must be ROI arguments');
end

roi_conv_hull = varargin{1};

if nargin == 1
  K = convhull(roi_conv_hull.ROIPolyX, roi_conv_hull.ROIPolyY);
  roi_conv_hull.ROIPolyX = roi_conv_hull.ROIPolyX(K);
  roi_conv_hull.ROIPolyY = roi_conv_hull.ROIPolyY(K);
  return;
end

for kk = 2:length(varargin)
  poly_x = [roi_conv_hull.ROIPolyX(:); varargin{kk}.ROIPolyX(:)];
  poly_y = [roi_conv_hull.ROIPolyY(:); varargin{kk}.ROIPolyY(:)];
  K = convhull(poly_x, poly_y);
  roi_conv_hull.ROIPolyX = poly_x(K);
  roi_conv_hull.ROIPolyY = poly_y(K);
end
