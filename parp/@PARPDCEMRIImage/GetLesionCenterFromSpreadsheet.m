function lesion_center_xy_mm = GetLesionCenterFromSpreadsheet(obj)
% Get lesion center in image coordinates from spreadsheet

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

str_pre_or_post_chemo = obj.ImageTag;

spreadsheet_values = get_spreadsheet_info(obj.PatientID);
if strcmp(str_pre_or_post_chemo, 'pre')
  lesion_center_mm = [spreadsheet_values.x_mm, spreadsheet_values.y_mm, spreadsheet_values.z_mm];

  if strcmpi(spreadsheet_values.slice_plane, 'sagittal')
    lesion_center_xy_mm = lesion_center_mm(2:3);
  elseif strcmpi(spreadsheet_values.slice_plane, 'axial')
    lesion_center_xy_mm = lesion_center_mm(1:2);
  else
    error('LesionCenter:NoSlicePlane', 'No slice plane specified for patient %d', obj.PatientID);
  end
else
  lesion_center_mm = [spreadsheet_values.x_mm_post, spreadsheet_values.y_mm_post, spreadsheet_values.z_mm_post];

  if strcmpi(spreadsheet_values.slice_plane_post, 'sagittal')
    lesion_center_xy_mm = lesion_center_mm(2:3);
  elseif strcmpi(spreadsheet_values.slice_plane_post, 'axial')
    lesion_center_xy_mm = lesion_center_mm(1:2);
  else
    error('LesionCenter:NoSlicePlane', 'No slice plane specified for patient %d', obj.PatientID);
  end
end
