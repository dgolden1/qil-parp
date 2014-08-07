function sets = subsets(vals, varargin)
% Get all subsets of all sizes of a list of numbers
% sets = subsets(vals, 'param', value, ...)
% 
% Just runs nchoosek a bunch of times
% 
% PARAMETERS
% b_include_empty: include empty set (default: false)
% b_print: print sets (default: false)

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id: subsets.m 337 2013-07-10 16:25:15Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('b_include_empty', false);
p.addParamValue('b_print', false);
p.parse(varargin{:});

%% Get index subsets
index_sets = {};
for kk = 1:length(vals)
  this_set = nchoosek(1:length(vals), kk);
  index_sets = [index_sets, mat2cell(this_set, ones(size(this_set, 1), 1), size(this_set, 2)).'];
end

%% Get actual subsets
sets = cellfun(@(x) vals(x), index_sets, 'uniformoutput', false);

if p.Results.b_include_empty
  if iscell(vals)
    sets = [{{}} sets];
  else
    sets = [{[]} sets];
  end
end

%% Print
if p.Results.b_print
  for kk = 1:length(sets)
    fprintf('(%s)\n', make_comma_separated_list(sets{kk}));
  end
end