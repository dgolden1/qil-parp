function b_is_stanford_scan = is_stanford_scan(patient_id, str_pre_or_post)
% True if the given patient id was scanned at Stanford
% b_is_stanford_scan = is_stanford_scan(patient_id, str_pre_or_post)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

si = get_spreadsheet_info;

switch str_pre_or_post
  case 'pre'
    study_location = {si.pre_mri_location};
  case 'post'
    study_location = {si.post_mri_location};
end

spreadsheet_stanford_idx = strcmpi(study_location, 'stanford');
spreadsheet_stanford_ids = [si(spreadsheet_stanford_idx).study_id];

b_is_stanford_scan = ismember(patient_id, spreadsheet_stanford_ids);
