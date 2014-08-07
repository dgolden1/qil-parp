function patient_ids = GetPatientList(obj)
% Get a list of all patient IDs

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

patient_ids = [];

d = dir(fullfile(obj.Dirname, 'patient*.mat'));
for kk = 1:length(d)
  patient_ids(kk) = PARPDB.GetPatientIDFromFilename(d(kk).name);
end
