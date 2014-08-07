function RemoveExcludedPatients(obj)
% Remove patients that have been excluded via the get_excluded_patient_list function

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

patient_ids = GetPatientList(obj);
excluded_ids = get_excluded_patient_list;

for kk = 1:length(excluded_ids)
  if ismember(excluded_ids(kk), patient_ids)
    RemoveFromDB(obj, excluded_ids(kk));
  end
end
