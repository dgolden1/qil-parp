function Y_positive_class_label = get_positive_class_label(Y)
% Define the positive class label of a binary-valued vector of classes as
% the first one when they're sorted alphabetically

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

Y_unique = unique(Y);

if length(Y_unique) ~= 2
  error('Y should have exactly two unique values');
end

Y_positive_class_label = Y_unique{1};
