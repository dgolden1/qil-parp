function sort_idx = multi_sort(varargin)
% Sort by a bunch of different criteria
% sort_idx = multi_sort(crit1, crit2, ...)
% 
% INPUTS
% Vectors, one for each sort criteria. Output index is sorted first by the
% first criteria, etc.
% 
% OUTPUTS
% sort_idx: sort index into crit1, crit2, etc... such that crit1(sort_idx)
% is sorted

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: multi_sort.m 91 2012-11-08 22:20:20Z dgolden $

if length(varargin) ~= 1 && ~all(cellfun(@length, varargin(2:end)) == length(varargin{1}))
  error('All criteria must be the same length');
end

sort_idx = 1:length(varargin{end});
for kk = 1:length(varargin)
  this_crit = varargin{end - kk + 1};
  this_crit = this_crit(sort_idx);
  [~, this_sort_idx] = sort(this_crit);
  sort_idx = sort_idx(this_sort_idx);
end