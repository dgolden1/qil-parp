function obj = SortByZ(obj)
% Sort ROIs by Z

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

[obj.ROIZValues, sort_idx] = sort(obj.ROIZValues);
obj.ROIs = obj.ROIs(sort_idx);
