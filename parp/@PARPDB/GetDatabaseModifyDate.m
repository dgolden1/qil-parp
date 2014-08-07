function modify_date = GetDatabaseModifyDate(obj)
% Get data of most recent change to the database

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$


patient_ids = GetPatientList(obj);
file_dates = zeros(size(patient_ids));
for kk = 1:length(patient_ids)
  filename = GetPatientFilenameFromID(obj, patient_ids(kk));
  d = dir(filename);
  file_dates(kk) = d.datenum;
end

modify_date = max(file_dates);
