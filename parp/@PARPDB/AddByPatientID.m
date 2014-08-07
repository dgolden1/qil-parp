function AddByPatientID(obj, patient_id)
% Add a patient to the PARPDB by patient ID
% Performs the role of the old get_and_combine_slices.m

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

get_and_combine_slices(patient_id, obj.PreOrPostChemo, false, false);

PDMI = PARPDCEMRIImage.CreateFromExistingOldStyle(patient_id, obj.PreOrPostChemo);

AddToDB(obj, PDMI);
