function obj = MetalMaskAggressive(obj)
% Mask out slices with metal (HU > 3000) within 15 pixels of the ROI and within a
% 1-slice radius
% Meant for CT images only

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

% Anything with HU > 3000 is considered metal
% This is the same cutoff as in Ed Boas' Metal Deletion Technique (MDT,
% http://www.revisionrads.com/)
metal_hu_cutoff = 3000;

% Dilate the ROI mask to get all voxels within some radius of the ROI
SE = strel('disk', 15);
roi_mask_dilated = imdilate(obj.MyROI3D.GetROIMask, SE);

image_volume_masked = obj.ImageVolume;
image_volume_masked(~roi_mask_dilated) = nan;

slices_with_metal = any(reshape(image_volume_masked, size(obj.ImageVolume, 1)*size(obj.ImageVolume, 2), size(obj.ImageVolume, 3)) > metal_hu_cutoff);
slices_with_metal_dilated = imdilate(slices_with_metal, [1 1 1]); % All slices within one slice of metal

% Set the portion of the slice within the dilated ROI to nan
obj.ImageVolume(roi_mask_dilated & repmat(reshape(slices_with_metal_dilated, [1 1 length(slices_with_metal_dilated)]), ...
  [size(obj.ImageVolume, 1), size(obj.ImageVolume, 2), 1])) = nan;

% Set the whole slice to nan  
% image_volume(:,:,slices_with_metal_dilated) = nan;
