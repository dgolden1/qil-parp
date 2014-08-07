function img = GetImage(obj)
% Get the DICOM image and convert to double

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

img = double(dicomread(obj.Filename));

if isempty(obj.RescaleSlope)
  rescale_slope = 1;
else
  rescale_slope = obj.RescaleSlope;
end

if isempty(obj.RescaleIntercept)
  rescale_intercept = 0;
else
  rescale_intercept = obj.RescaleIntercept;
end

img = img*rescale_slope + rescale_intercept;
