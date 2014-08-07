function img = GetImageNanOutsideROI(obj)
% Image with the region outside the ROI set to NaN

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: GetImageNanOutsideROI.m 247 2013-04-19 21:57:06Z dgolden $

img = obj.Image;

if ~isempty(obj.MyROI)
  img(~obj.MyROI.ROIMask) = nan;
end