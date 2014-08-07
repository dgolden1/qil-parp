function value = isunique(array)
% Return true if array is unique

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: isunique.m 190 2013-02-15 01:19:37Z dgolden $

value = isequal(sort(array), unique(array));