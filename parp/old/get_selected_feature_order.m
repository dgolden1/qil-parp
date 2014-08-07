function inmodel_sorted = get_selected_feature_order(history)
% Sort selected features from sequential feature selection by order in
% which they were picked

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

if size(history.In, 1) <= 1
  inmodel_sorted = find(history.In);
else
  d = [history.In(1,:); diff(history.In)];
  for kk = 1:size(d, 1)
    inmodel_sorted(kk) = find(d(kk,:));
  end
end
