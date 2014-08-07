function roi_pixels = GetROIPixels(obj, varargin)
% Get a vector of pixels within the ROI
% 
% PARAMETERS
% b_tighten_roi: tighten ROI for Lung CT lesions

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_tighten_roi', false);
p.parse(varargin{:});

%% Get mask and tighten, if requested
if p.Results.b_tighten_roi
  roi_mask_3d = GetTightenedLungMask(obj);
else
  roi_mask_3d = obj.MyROI3D.GetROIMask;
end

%% Return pixels
roi_pixels = obj.ImageVolume(roi_mask_3d);
