function lesion_center_xy_mm = get_lesion_center_from_spreadsheet(patient_id, str_pre_or_post_chemo)
% Get lesion center in image coordinates from spreadsheet

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

spreadsheet_values = get_spreadsheet_info(patient_id);
if strcmp(str_pre_or_post_chemo, 'pre')
  lesion_center_mm = [spreadsheet_values.x_mm, spreadsheet_values.y_mm, spreadsheet_values.z_mm];

  if strcmpi(spreadsheet_values.slice_plane, 'sagittal')
    lesion_center_xy_mm = lesion_center_mm(2:3);
  elseif strcmpi(spreadsheet_values.slice_plane, 'axial')
    lesion_center_xy_mm = lesion_center_mm(1:2);
  else
    error('LesionCenter:NoSlicePlane', 'No slice plane specified for patient %d', patient_id);
  end
else
  lesion_center_mm = [spreadsheet_values.x_mm_post, spreadsheet_values.y_mm_post, spreadsheet_values.z_mm_post];

  if strcmpi(spreadsheet_values.slice_plane_post, 'sagittal')
    lesion_center_xy_mm = lesion_center_mm(2:3);
  elseif strcmpi(spreadsheet_values.slice_plane_post, 'axial')
    lesion_center_xy_mm = lesion_center_mm(1:2);
  else
    error('LesionCenter:NoSlicePlane', 'No slice plane specified for patient %d', patient_id);
  end
end

