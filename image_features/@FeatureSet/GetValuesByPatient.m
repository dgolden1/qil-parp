function values = GetValuesByPatient(obj, patient_ids)
% Get some values from the FeatureVector by patient id

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

if ~exist('patient_ids', 'var') || isempty(patient_ids)
  idx_patients = (1:length(obj.PatientIDs)).';
else
  idx_patients = ismember(obj.PatientIDs, patient_ids);
  
  if sum(idx_patients) == 0
    error('Given patient IDs not found in database');
  end
end

values = obj.FeatureVector(idx_patients, :);
