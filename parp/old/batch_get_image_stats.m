function [stats_struct, patient_ids] = batch_get_image_stats(str_pre_or_post_chemo, b_pre_post)
% Get some statistics about the images for all patients
% [stats_struct, patient_ids] = batch_get_image_stats(str_pre_or_post_chemo, b_pre_post)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
if ~exist('b_pre_post', 'var') || isempty(b_pre_post)
  b_pre_post = false;
end

patient_ids = get_processed_patient_list(str_pre_or_post_chemo);

for kk = 1:length(patient_ids)
  t_start = now;
  this_patient_id = patient_ids(kk);
  if exist(fullfile(get_patient_dir_from_id(this_patient_id, str_pre_or_post_chemo), 'pre_post'), 'dir')
    [slice_filename, roi_filename] = get_slice_filename(this_patient_id, str_pre_or_post_chemo, [], b_pre_post);
  else
    [slice_filename, roi_filename] = get_slice_filename(this_patient_id, str_pre_or_post_chemo, [], false);
  end
  
  slice = load(slice_filename);
  
  stats_struct(kk).patient_id = this_patient_id;
  stats_struct(kk).pixel_spacing = slice.info(1).PixelSpacing(1);
  stats_struct(kk).slice_thickness = slice.info(1).SliceThickness;
  stats_struct(kk).series_name = slice.info(1).SeriesDescription;
  stats_struct(kk).dt = median(diff([slice.t]));
  stats_struct(kk).dt_max = max(diff([slice.t]));
  stats_struct(kk).b_registered = isfield(slice, 'b_registered') && slice.b_registered;
  stats_struct(kk).num_time_points = length(slice.info);
  
  acquisition_date = slice.info(1).AcquisitionDate;
  year = str2double(acquisition_date(1:4));
  month = str2double(acquisition_date(5:6));
  day = str2double(acquisition_date(7:8));
  stats_struct(kk).image_date = datenum([year, month, day, 0, 0, 0]);
  
  if isempty(roi_filename)
    stats_struct(kk).roi_num_pts = nan;
  else
    roi = load(roi_filename);
    stats_struct(kk).roi_num_pts = length(roi.roi_poly.img_x_mm);
  end
  
  fprintf('Processed patient %d (%d of %d) in %s\n', this_patient_id, kk, length(patient_ids), time_elapsed(t_start, now));
end
