function obj = RemoveFromDB(obj, patient_id)
% Remove an entry from the database by patient ID

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Allow removal of multiple patients
if ~ischar(patient_id) && length(patient_id) > 1
  for kk = 1:length(patient_id)
    if iscell(patient_id)
      this_patient_id = patient_id{kk};
    else
      this_patient_id = patient_id(kk);
    end
    RemoveFromDB(obj, this_patient_id);
  end
  return;
end

%% Run
filename = GetPatientFilenameFromID(obj, patient_id);

if exist(filename, 'file')
  delete(filename);
  fprintf('Removed patient %03d from database\n', patient_id);
else
  error('Patient %03d does not exist in database', patient_id);
end
