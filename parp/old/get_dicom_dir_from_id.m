function dicom_dir = get_dicom_dir_from_id(patient_id, str_pre_or_post_chemo, b_create_if_no_exist)
% Get directory of DICOM files from patient ID
% dicom_dir = get_dicom_dir_from_id(patient_id, str_pre_or_post_chemo)
% 
% str_pre_or_post_chemo can be either 'pre' or 'post'

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012

%% Setup
if ~exist('b_create_if_no_exist', 'var') || isempty(b_create_if_no_exist)
  b_create_if_no_exist = false;
end

%% Run
patient_dir = get_patient_dir_from_id(patient_id, str_pre_or_post_chemo, b_create_if_no_exist);
dicom_dir = strrep(patient_dir, 'matlab', 'dicom_anon');

