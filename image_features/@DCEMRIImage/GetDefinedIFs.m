function if_list = GetDefinedIFs(obj)
% Get a list of defined (non-empty) ImageFeature objects

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

% List ImageFeature properties (ones that start with IF)
p = properties(obj);
p = p(cellfun(@(x) ~isempty(regexp(x, '^IF[A-Z]', 'once')), p));

% For each ImageFeature property, add its name to the output list if that property
% is not empty
if_list = {};
for kk = 1:length(p)
  if ~isempty(obj.(p{kk}))
    if_list{end+1} = p{kk};
  end
end
