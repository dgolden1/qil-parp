function str = make_comma_separated_list(cell_str, str_seperator)
% Make a comma-separated list from a cellstring
% str = make_comma_separated_list(cell_str, str_seperator)
% 
% By default, str_seperator = ', '

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: make_comma_separated_list.m 228 2013-03-29 21:27:41Z dgolden $

%% Setup
if ~exist('str_seperator', 'var') || isempty(str_seperator)
  str_seperator = ', ';
end

str = '';

if isempty(cell_str)
  return;
elseif isnumeric(cell_str) || islogical(cell_str)
  cell_str = cellfun(@num2str, num2cell(cell_str), 'uniformoutput', false);
elseif ~iscellstr(cell_str)
  error('Input must be a numeric array or a cell string');
end

for kk = 1:length(cell_str)
  % Don't add cell object if empty
  if isempty(cell_str{kk})
    continue;
  end
  
  if isempty(str)
    str = cell_str{kk};
  else
    str = [str, str_seperator, cell_str{kk}];
  end
end