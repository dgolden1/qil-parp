function obj = RemoveInvalidPatients(obj, b_verbose)
% Remove patients with any NaN features

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('b_verbose', 'var') || isempty(b_verbose)
  b_verbose = true;
end

idx_nan = any(~isfinite(obj.FeatureVector), 2);
ids_to_remove = obj.PatientIDs(idx_nan);
obj = RemovePatients(obj, ids_to_remove, b_verbose, 'with non-finite features');
