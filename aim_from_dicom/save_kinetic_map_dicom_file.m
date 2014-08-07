function [output_filename, new_roi_mask, new_x_coord_mm, new_y_coord_mm] = save_kinetic_map_dicom_file(patient_id, output_dir, map_str, b_normalize_histogram, b_expand_roi)
% Save a kinetic map as a DICOM file
% [output_filename, new_roi_mask, new_x_coord_mm, new_y_coord_mm] = save_kinetic_map_dicom_file(patient_id, output_dir, map_str, b_normalize_histogram)
% 
% Regions outside of the ROI will be set to 0
% map_str can be one of 'ktrans', 'kep', 've', or 'empirical'

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

if ~exist('b_normalize_histogram', 'var') || isempty(b_normalize_histogram)
  b_normalize_histogram = false;
end
if ~exist('b_expand_roi', 'var') || isempty(b_expand_roi)
  b_expand_roi = false;
end

%% Load slice
[slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id);

info = [];
load(roi_filename);
load(slice_filename);
[x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);

switch map_str
  case {'ktrans', 'kep', 've'}
    load(pk_filename);
    map_str_vec = {'ktrans', 'kep', 've'};
    map_vec = {ktrans, kep, ve};
    map = map_vec{strcmpi(map_str_vec, map_str)};
  case {'wash_in', 'wash_out', 'auc'}
    [~, ~, slices_masked_vec] = mask_2d_nd(slices, roi_mask);
    [wash_in_slope, wash_out_slope, area_under_curve] = get_empirical_params(slices_masked_vec, info, t);
    map_str_vec = {'wash_in', 'wash_out', 'auc'};
    map_vec = {wash_in_slope, wash_out_slope, area_under_curve};
    map = map_vec{strcmpi(map_str_vec, map_str)};
  otherwise
    error('Invalid map_str: %s', map_str);
end

%% Resize image to common resolution
res_common = 1; % mm
res_orig = abs(median(diff(x_coord_mm)));
scale_factor = res_orig/res_common;

b_constrain_output = false;
[img, new_roi_mask, new_x_coord_mm, new_y_coord_mm] = resize_img_and_roi(map, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_constrain_output);
img(img< 0) = 0;

%% Expand ROI
if b_expand_roi
  error('Not implemented yet');
  
  % Find new pixels that we need to calculate
  roi_mask_dilated = imdilate(new_roi_mask, strel('disk', 5));
  roi_mask_new = roi_mask_dilated - roi_mask;

  % Resize the original slices
  for kk = 1:size(slices, 3)
    slices_resized(:,:,kk) = imresize(slices(:,:,kk), scale_factor);
  end

  % Calculate new kinetic parameters
  switch map_str
    case {'wash_in', 'wash_out', 'auc'}
      [~, ~, slices_masked_vec] = mask_2d_nd(slices_resized, roi_mask_dilated);
      [wash_in_slope, wash_out_slope, area_under_curve] = get_empirical_params(slices_masked_vec, info, t);
      map_str_vec = {'wash_in', 'wash_out', 'auc'};
      map_vec = {wash_in_slope, wash_out_slope, area_under_curve};
      map = map_vec{strcmpi(map_str_vec, map_str)};
  end
end

%% Normalize histogram
if b_normalize_histogram
  % Make lesion values go from 0 to 4096 (number chosen by Jiajing for
  % breast MRI range)
  max_img_value = 4096;
  
  img = (img - min(img(new_roi_mask)))/range(img(new_roi_mask))*max_img_value;
  img(img > max_img_value) = max_img_value;
  img(img < 0) = 0;
end

%% Save file
output_filename = fullfile(output_dir, sprintf('%03dPRE_%s.dcm', patient_id, map_str));
dicomwrite(uint16(img), output_filename, info(1));
fprintf('Wrote %s\n', output_filename);
