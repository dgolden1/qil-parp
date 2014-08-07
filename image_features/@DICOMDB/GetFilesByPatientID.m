function dicom_list = GetFilesByPatientID(obj, patient_id, modality)
% Get a vector of DICOMImage files for just the given patient ID

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

idx = strcmp({obj.DICOMList.PatientID}, patient_id);

if exist('modality', 'var') && ~isempty(modality)
  idx = idx & strcmp({obj.DICOMList.Modality}, modality);
end

dicom_list = obj.DICOMList(idx);
