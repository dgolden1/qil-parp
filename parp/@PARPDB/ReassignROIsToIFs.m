function ReassignROIsToIFs(obj)
% In an earlier version of my code, the IF properties in the PARPDCEMRIImage properties
% didn't always get the ROIs from the PARPDCEMRIImage objects. Fix this

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

patient_ids = obj.GetPatientList;
for kk = 1:length(patient_ids)
  PDMI = GetPatientImage(obj, patient_ids(kk));
  image_features = GetDefinedIFs(PDMI);
  assert(length(image_features) == 7);
  
  for jj = 1:length(image_features)
    PDMI.(image_features{jj}).MyROI = PDMI.MyROI;
  end
  
  AddToDB(obj, PDMI);
end
