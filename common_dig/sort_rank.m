function rank = sort_rank(array)
% Get the rank of each element of a vector
% This is different from, but related to, sorting the vector
% Only works in ascending order
% 
% e.g., for the array [1 3 2 0], the answer is [2 4 3 1]
% because 0 is ranked first, 1 is ranked second, etc.

% By Daniel Golden (dgolden1 at stanford dot edu) April 2013
% $Id: sort_rank.m 232 2013-04-04 00:09:59Z dgolden $

[~, idx] = sort(array);
[~, rank] = sort(idx);