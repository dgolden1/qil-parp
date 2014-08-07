function [X, X_names, patient_ids] = combine_features(X_cell, X_names_cell, patient_ids_cell)
% Combine multiple features together
% [X, X_names, patient_ids] = combine_features(X_cell, X_names_cell, patient_ids_cell)
% 
% Inputs are cell arrays of the features, with a different feature set for
% each index
% 
% Outputs are combined features for all common patient IDs

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

X = [];
X_names = {};

% Find common patients
patient_ids = patient_ids_cell{1};
for kk = 2:length(X_cell)
  patient_ids = intersect(patient_ids, patient_ids_cell{kk});
end
patient_ids = sort(patient_ids);

% Combine features
for kk = 1:length(X_cell)
  [this_patient_id, idx_sort] = sort(patient_ids_cell{kk});
  this_X = X_cell{kk}(idx_sort, :);
  
  X = [X this_X(ismember(this_patient_id, patient_ids), :)];
  X_names = [X_names X_names_cell{kk}];
end
