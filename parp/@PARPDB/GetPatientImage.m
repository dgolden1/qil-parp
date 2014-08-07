function PDMI_list = GetPatientImage(obj, patient_ids)
% Get one or more patient images

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if any(~ismember(patient_ids, obj.GetPatientList))
  invalid_patient_id = patient_ids(find(~ismember(patient_ids, obj.GetPatientList), 1));
  error('Patient %03d does not exist in database', invalid_patient_id);
end

for kk = 1:length(patient_ids)
  filename = GetPatientFilenameFromID(obj, patient_ids(kk));
  PDMI = load_object_properties(filename);
  PDMI_list(kk) = PDMI;
end
