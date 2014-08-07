function [X, X_names, patient_id] = struct_to_feature_vector(my_struct)
% Convert a structure or structure array to a feature vector
% All fields of input struct except for 'patient_id' will be returned in
% the feature vector

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~isfield(my_struct, 'patient_id')
  error('patient_id must be a field in input structure');
end
patient_id = [my_struct.patient_id].';

fn = fieldnames(rmfield(my_struct, 'patient_id'));

X = nan(length(my_struct), length(fn));
X_names = cell(1, length(fn));
for kk = 1:length(fn)
  X(:,kk) = [my_struct.(fn{kk})].';
  X_names{kk} = fn{kk};
end
