function obj = SortPatients(obj)
% Sort patients in ascending order

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

[~, idx_sort] = sort(obj.PatientIDs);
obj.PatientIDs = obj.PatientIDs(idx_sort);
obj.FeatureVector = obj.FeatureVector(idx_sort, :);

if ~isempty(obj.Response)
  obj.Response = obj.Response(idx_sort);
end
