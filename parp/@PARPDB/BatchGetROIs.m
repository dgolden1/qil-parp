function BatchGetROIs(obj)
% Get ROIs for all PARPDCEMRIImage objects for which there is no existing ROI

% By Daniel Golden (dgolden1 at stanford dot edu) Feburary 2013
% $Id$

% patient_ids = GetPatientList(obj);
% 
% for kk = 1:length(patient_ids)
%   patient_id = patient_ids(kk);
%   
%   load(GetPatientFilenameFromID(obj, patient_id), 'MyROI');
%   
%   if isempty(MyROI)
%     PDMI = GetPatientImage(obj, patient_id);
%     PDMI = CreateROI(PDMI);
%     AddToDB(obj, PDMI);
%     
%     fprintf('Created ROI for patient %s (%d of %d)\n', patient_id_tostr(patient_id), kk, length(patient_ids));
%   else
%     fprintf('Skipped patient %s (%d of %d): ROI is already defined\n', patient_id_tostr(patient_id), kk, length(patient_ids));
%   end
% end

BatchFun(obj, @CreateROI, 'b_save_modified_PDMIs', true, 'b_process_fun', @(x) bool_process_fun(obj, x));


function b_process = bool_process_fun(obj, patient_id)
% Return true if we want to process this patient

load(GetPatientFilenameFromID(obj, patient_id), 'MyROI');
b_process = isempty(MyROI);
