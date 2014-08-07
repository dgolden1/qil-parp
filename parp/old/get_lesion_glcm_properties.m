function [glcm_stats, glcm] = get_lesion_glcm_properties(x_mm, y_mm, z_mm, roi_mask, roi_poly, maps, map_names)
% Get texture from gray-level co-occurrence matrices
% glcm_stats = get_lesion_glcm_properties(x_mm, y_mm, z_mm, roi_mask, maps, map_names)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
b_new_resolution_fix = true;
common_resolution = 1.5; % mm/pixel

%% Get pixel resolution
[x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);
assert(abs(abs(median(diff(x_coord_mm))) - abs(median(diff(y_coord_mm)))) < 0.1); % Make sure x and y resolution are about equal
mm_per_pixel = abs(median(diff(x_coord_mm)));

if ~b_new_resolution_fix
  % The old way to deal with different image resolutions: change the "reach" of the GLCM matrix
  % A kludgey way of dealing with the fact that images are sampled at
  % different spatial resolutions; just dilate the gracomatrix's "offset"
  % parameter to the next-higher interger for higher-resolution data and
  % leave it at 1 for lower-resolution data
  grayco_dilation = max(round(1.5/mm_per_pixel), 1);
else
  % The new way: resize the image with the lanczos kernel
  grayco_dilation = 1;
end


%% Get GLCM for each parameter map (ktrans, kep, etc.)
grayco_offsets = [0 1; -1 1; -1 0; -1 -1]*grayco_dilation; % 0, 45, 90 and 135 degrees
numlevels = 8;

warning('off', 'Images:graycomatrix:scaledImageContainsNan'); % We know the image has NaNs
for kk = 1:length(maps)
  img_original = zeros(size(roi_mask));
  img_original(roi_mask) = maps{kk};
  if b_new_resolution_fix
    scale_factor = mm_per_pixel/common_resolution;
    
    % Don't allow resized maps of PK parameters to have values below zero
    if ismember(map_names{kk}, {'ktrans', 'kep', 've'})
      b_constrain_resized_output = true;
    else
      b_constrain_resized_output = false;
    end
    
    [map_resized, roi_mask_resized, x_coord_mm_resized, y_coord_mm_resized] = resize_img_and_roi(maps{kk}, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_constrain_resized_output);
    
    % Convert to log scale; otherwise, pixels tend to be smushed up at low
    % or high values.
    % But is this a good idea? We always look at the maps on a linear
    % scale...
    % imgs{kk} = log(img_resized);
    img_resized = nan(size(roi_mask_resized));
    img_resized(roi_mask_resized) = map_resized;
    imgs{kk} = img_resized;
  else
    img_original(~roi_mask) = nan;
    imgs{kk} = img_original;
  end
  
  [this_glcm_stats, glcm{kk}] = get_glcm_properties(imgs{kk}, grayco_offsets, [], numlevels);
  
  fn = fieldnames(this_glcm_stats);
  for jj = 1:length(fn)
    glcm_stats.(sprintf('%s_%s', map_names{kk}, lower(fn{jj}))) = this_glcm_stats.(fn{jj});
  end
end
warning('on', 'Images:graycomatrix:scaledImageContainsNan');

