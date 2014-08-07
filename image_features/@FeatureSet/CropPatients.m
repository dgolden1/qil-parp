function obj = CropPatients(obj, patient_ids_to_keep)
% Remove some patients by specifying patient IDs to keep

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

b_verbose = true;

if ~all(ismember(patient_ids_to_keep, obj.PatientIDs))
  error('Not all patient_ids_to_keep are in the PatientIDs list');
end
if isempty(patient_ids_to_keep)
  error('Attempting to remove all patients');
end

idx_remove = ~ismember(obj.PatientIDs, patient_ids_to_keep);
ids_to_remove = obj.PatientIDs(idx_remove);
obj = RemovePatients(obj, ids_to_remove, b_verbose, '');
