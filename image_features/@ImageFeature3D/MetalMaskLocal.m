function obj = MetalMaskLocal(obj)
% Locally mask out slices with metal (HU > 3000) isotropically within two pixels of the
% metal Meant for CT images only

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

% Anything with HU > 3000 is considered metal
% This is the same cutoff as in Ed Boas' Metal Deletion Technique (MDT,
% http://www.revisionrads.com/)
metal_hu_cutoff = 3000;

% Mask all pixels with HU values above a threshold
metal_mask_3d = obj.ImageVolume > metal_hu_cutoff;

% Dilate the mask to enclose the most egregious image artifacts that occur in the
% vicinity of the metal
SE = create_3d_strel(2);
metal_mask_3d_dilated = imdilate(metal_mask_3d, SE);

% Save original volume for debugging
image_volume_original = obj.ImageVolume;

% Remove the dilated metal mask from the original image
obj.ImageVolume(metal_mask_3d_dilated) = nan;

function SE = create_3d_strel(radius)
% Function: Create a 3D structuring element for dilation

x = (-radius:radius);
y = x;
z = x;
[X, Y, Z] = meshgrid(x, y, z);
R = sqrt(X.^2 + Y.^2 + Z.^2);
nhood = R <= radius;
SE = strel(nhood);
