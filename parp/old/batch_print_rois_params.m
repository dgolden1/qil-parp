function batch_print_rois_params
% Print patient ROIs for Katie Planey

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
addpath(fullfile('nicks_PK_code', 'DCE'));
addpath(fullfile('nicks_PK_code', 'LS'));

b_print_to_file = true;
output_dir = '~/temp';

%% Cycle through patients
[~, patient_dirs] = get_processed_patient_list;

for kk = 1:length(patient_dirs)
  this_patient_dir = patient_dirs{kk};
  patient_num = get_patient_id_from_name(just_filename(this_patient_dir));
  
  % Load ROI
  roi_file_list = dir(fullfile(this_patient_dir, '*roi*.mat'));
  if length(roi_file_list) ~= 1
    continue;
  end
  load(fullfile(this_patient_dir, roi_file_list.name), 'roi_poly', 'x_mm', 'y_mm', 'z_mm');
  [~, ~, x_label, y_label, slice_location_mm, slice_label, plane_name] = get_img_coords(x_mm, y_mm, z_mm);
  
  if b_print_to_file
    output_filename = fullfile(output_dir, sprintf('PARP_ROI_%03d.txt', patient_num));
    fid = fopen(output_filename, 'w');
  else
    fid = 1; % Print to screen
  end
  
  % Print ROI
  field_width = 7;
  fprintf(fid, 'Patient %03d ROI, %s plane, %s = %0.1f\n', patient_num, plane_name, slice_label, slice_location_mm);
  fprintf(fid, '% *s % *s\n', field_width, x_label, field_width, y_label);
  for jj = 1:length(roi_poly.img_x_mm)
    fprintf(fid, '% *.1f % *.1f\n', field_width, roi_poly.img_x_mm(jj), field_width, roi_poly.img_y_mm(jj));
  end
  
  if b_print_to_file
    fclose(fid);
    fprintf('Wrote %s\n', output_filename);
  end
end

function [roi_poly, x_mm, y_mm, z_mm] = load_roi(patient_dir)
%% Function: load ROI

b_skip_errors = false;

roi_file_list = dir(fullfile(patient_dir, '*roi*.mat'));

if isempty(roi_file_list)
  msg = sprintf('No roi files found in %s', patient_dir);
  if b_skip_errors
    fprintf('%s; skipping\n', msg);
    return;
  else
    error('getPK:noROIs', msg);
  end
elseif length(roi_file_list) > 1
  msg = sprintf('Multiple ROI files found in %s', patient_dir);
  if b_skip_errors
    fprintf('%s; skipping\n', msg);
    return;
  else
    error('getPK:multipleROIs', msg);
  end
end

load(fullfile(patient_dir, roi_file_list.name), 'roi_poly', 'x_mm', 'y_mm', 'z_mm');
