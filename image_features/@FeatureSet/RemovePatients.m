function obj = RemovePatients(obj, ids_to_remove, b_verbose, message_str)
% Remove patients

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Setup
if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = false;
end
if ~exist('message_str', 'var')
  message_str = '';
end
if ~isempty(message_str)
  message_str = [' ' message_str];
end

%% Remove patients
idx_remove = ismember(obj.PatientIDs, ids_to_remove);
removed_patient_ids = patient_id_tostr(obj.PatientIDs(idx_remove), true);
obj.FeatureVector(idx_remove, :) = [];
obj.PatientIDs(idx_remove) = [];

if ~isempty(obj.Response)
  obj.Response(idx_remove) = [];
end

%% Print
if any(idx_remove) && b_verbose
  fprintf('Removed patients%s:\n', message_str);
  for kk = 1:(length(removed_patient_ids) - 1)
    fprintf('%s, ', removed_patient_ids{kk});
  end
  fprintf('%s\n', removed_patient_ids{end});
end
