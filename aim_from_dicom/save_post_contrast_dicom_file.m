function [output_filename, new_roi_mask, new_x_coord_mm, new_y_coord_mm] = save_post_contrast_dicom_file(patient_id, output_dir, b_normalize_histogram)
% Save the POST DICOM image to a file
% save_post_dicom_file(patient_id, output_filename)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

if ~exist('b_normalize_histogram', 'var') || isempty(b_normalize_histogram)
  b_normalize_histogram = false;
end

%% Load slice
if exist(fullfile(get_patient_dir_from_id(patient_id), 'pre_post'), 'dir')
  b_pre_post = true;
  [slice_filename, roi_filename] = get_slice_filename(patient_id, [], true);
  % [~, roi_filename] = get_slice_filename(patient_id, [], false);
else
  b_pre_post = false;
  [slice_filename, roi_filename] = get_slice_filename(patient_id, [], false);
end

info = [];
load(roi_filename);
load(slice_filename);
[x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);

%% Find post-contrast slice
post_idx = max(2, interp1(t, 1:length(t), 180, 'nearest', 'extrap'));
post_slice = slices(:,:,post_idx);
post_info = info(post_idx);
if post_info.BitDepth ~= 16
  warning('BitDepth = %0.0f', post_info.BitDepth);
end

%% Resize image to common resolution
res_common = 1; % mm
res_orig = post_info.PixelSpacing(1);
scale_factor = res_orig/res_common;

b_contstrain_output = false;
[post_slice, new_roi_mask, new_x_coord_mm, new_y_coord_mm] = resize_img_and_roi(post_slice, roi_poly, roi_mask, x_coord_mm, y_coord_mm, scale_factor, b_contstrain_output);
post_info.PixelSpacing = res_common*[1 1];

%% Normalize histogram
if b_normalize_histogram
  % Make lesion values go from 0 to 4096 (number chosen by Jiajing for
  % breast MRI range)
  max_img_value = 4096;
  
  post_slice = (post_slice - min(post_slice(new_roi_mask)))/range(post_slice(new_roi_mask))*max_img_value;
  post_slice(post_slice > max_img_value) = max_img_value;
  post_slice(post_slice < 0) = 0;
end

%% Save file
output_filename = fullfile(output_dir, sprintf('%03dPRE_post_contrast.dcm', patient_id));
dicomwrite(uint16(post_slice), output_filename, post_info);
fprintf('Wrote %s\n', output_filename);
