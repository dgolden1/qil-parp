function positive_class_label = DeterminePositiveClassLabel(obj)
% Determine positive class label for categorical response
% positive_class_label = DeterminePositiveClassLabel(obj)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$


if ~strcmp(obj.Type, 'binomial')
  positive_class_label = {};
  return
end

Y_unique = unique(obj.Y);

if iscellstr(Y_unique)
  positive_class_label = Y_unique{1};
elseif isnumeric(Y_unique) || islogical(Y_unique)
  positive_class_label = Y_unique(1);
else
  error('Invalid class for Y: %s', class(obj.Y));
end
