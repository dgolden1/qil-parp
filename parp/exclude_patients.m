function lesions = exclude_patients(lesions, b_stanford_only, str_pre_or_post)
% Remove a predetermined set of outliers from the lesion list
% 
% These are determined because the cases themselves are unique - not
% just because they don't fit the model

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
if ~exist('b_stanford_only', 'var') || isempty(b_stanford_only)
  b_stanford_only = false;
end

excluded_patient_ids = get_excluded_patient_list;
patient_ids = [lesions.patient_id];

% Also exclude patients with no RCB (rcb_val = NaN)
bad_indices = ismember(patient_ids, excluded_patient_ids) | ~isfinite([lesions.rcb_val]);

if b_stanford_only
  bad_indices = bad_indices | ~is_stanford_scan(patient_ids, str_pre_or_post);
end

lesions(bad_indices) = [];
