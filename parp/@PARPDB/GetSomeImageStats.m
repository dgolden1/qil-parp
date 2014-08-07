function stats_struct = GetSomeImageStats(obj)
% Run PARPDCEMRIImage.GetSomeImageStats on each object in database and return a struct
% vector

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

patient_ids = obj.GetPatientList;
for kk = 1:length(patient_ids)
  t_start = now;
  stats_struct(kk) = GetSomeImageStats(GetPatientImage(obj, patient_ids(kk)));
  fprintf('Processed patient %d (%d of %d) in %s\n', patient_ids(kk), kk, length(patient_ids), time_elapsed(t_start, now));
end
