function obj = ClearDB(obj)
% Delete all files in database

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$
  
response = input('WARNING: This will irreversibly delete the %s database. Type ''DELETE'' to proceed: ', 's');

if ~strcmp(response, 'DELETE')
  fprintf('No action taken\n');
  return;
end

patient_ids = GetPatientList(obj);

for kk = 1:length(patient_ids)
  obj = RemoveFromDB(obj, patient_ids(kk));
end
end

