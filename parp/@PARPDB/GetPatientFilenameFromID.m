function filename = GetPatientFilenameFromID(obj, patient_id)
% Get patient filename from ID

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

filename = fullfile(obj.Dirname, sprintf('patient_%03d_%s.mat', patient_id, obj.PreOrPostChemo));
