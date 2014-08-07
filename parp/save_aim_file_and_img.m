function [dicom_filename, aim_filename] = save_aim_file_and_img(patient_id, img_type_str)
% Save PARP post-contrast DICOM image and convert ROI to an AIM file

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
output_dir = fullfile(qilcasestudyroot, 'dicom_aim_for_jiajing_pipeline', sprintf('dicom_aim_%s', img_type_str));
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

b_normalize_dicom_histogram = true;

%% Generate unique identifier string
[~, unique_identifier_str] = system(sprintf('echo %03d -n | md5', patient_id));

% Remove newline
unique_identifier_str(end) = [];

%% Make DICOM file
switch lower(img_type_str)
  case 'post_img'
    [dicom_filename, roi_mask, x_coord_mm, y_coord_mm] = save_post_contrast_dicom_file(patient_id, output_dir, b_normalize_dicom_histogram);
  otherwise
    [dicom_filename, roi_mask, x_coord_mm, y_coord_mm] = save_kinetic_map_dicom_file(patient_id, output_dir, img_type_str, b_normalize_dicom_histogram);
end
    

%% Convert ROI from DICOM coordinates to image coordinates
if exist(fullfile(get_patient_dir_from_id(patient_id), 'pre_post'), 'dir')
  [~, roi_filename] = get_slice_filename(patient_id, [], true);
else
  [~, roi_filename] = get_slice_filename(patient_id, [], false);
end

load(roi_filename, 'roi_poly');
[x_roi_px, y_roi_px] = roi_mm_to_px(x_coord_mm, y_coord_mm, roi_poly.img_x_mm, roi_poly.img_y_mm);

aim_filename = strrep(dicom_filename, '.dcm', '_AIM_ROI.xml');

%% Make AIM template
generate_aim_file_from_roi(x_roi_px, y_roi_px, aim_filename, dicom_filename, unique_identifier_str);
