function batch_register_patient_slices
% Loop over patients and register slices

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

patient_ids = get_processed_patient_list;

for kk = 1:length(patient_ids)
  register_patient_slices_auto(patient_ids(kk));
end
