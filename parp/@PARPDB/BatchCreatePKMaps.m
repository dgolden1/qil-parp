function BatchCreatePKMaps(obj)
% Create PK maps for all patients

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

BatchFun(obj, @CreatePKMaps, 'b_save_modified_PDMIs', true, 'b_process_fun', @(x) bool_process_fun(obj, x));

function b_process = bool_process_fun(obj, patient_id)
% Return true if we want to process this patient

load(GetPatientFilenameFromID(obj, patient_id), 'IFKep');
b_process = isempty(IFKep);

1;
