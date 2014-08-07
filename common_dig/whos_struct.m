function whos_struct(var)
% Run the matlab 'whos' function on the fields of a struct
% Useful for seeing what fields take up lots of memory

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: whos_struct.m 165 2013-01-29 21:05:15Z dgolden $

if isobject(var)
  s = warning('off', 'MATLAB:structOnObject');
  var = struct(var);
  warning(s.state, 'MATLAB:structOnObject');
elseif ~isstruct(var)
  error('input must be a struct or class');
end

fn = fieldnames(var);
for kk = 1:length(fn)
  if length(var) == 1
    eval(sprintf('%s = %s.%s;', fn{kk}, 'var', fn{kk}));
  else
    % If this is a struct array, group fields into cell arrays
    eval(sprintf('%s = {%s.%s};', fn{kk}, 'var', fn{kk}));
  end
end

clear var fn kk;
whos;