function obj = TightenLungCTROI(obj, varargin)
% Tighten the ROI to a lung lesion on CT by masking out normal-looking lung tissue
% 
% PARAMETERS
% tightening_thresh (default: -400)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('tightening_thresh', -400);
p.parse(varargin{:});


%% Tighten ROI mask
mask_tightened = GetTightenedLungMask(obj);

assert(length(obj.SpatialZCoords) == size(mask_tightened, 3));

%% Create new ROI3D object by converting ROI mask to polygons
ROIs = ROI.empty;
z_vals_mm = [];
for kk = 1:size(mask_tightened, 3)
  this_z_val = obj.SpatialZCoords(kk);
  
  mask2d = mask_tightened(:,:,kk);
  if sum(mask2d(:)) == 0
    continue;
  else
    ROIs(end+1, 1) = ROI([], [], obj.SpatialXCoords, obj.SpatialYCoords, 'ROIMask', mask2d, 'b_store_mask', true);
    z_vals_mm(end+1, 1) = this_z_val;
  end
end

new_ROI3D = ROI3D(ROIs, interp1(obj.SpatialZCoords, 1:length(obj.SpatialZCoords), z_vals_mm, 'nearest'), obj.SpatialZCoords);
obj.MyROI3D = new_ROI3D;
