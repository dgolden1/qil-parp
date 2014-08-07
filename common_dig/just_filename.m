function filename = just_filename(filename)
% filename = just_filename(filename)
% Returns the filename (including extension) without the path

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id: just_filename.m 13 2012-08-10 19:30:42Z dgolden $

if isstr(filename)
  [pathstr name ext] = fileparts(filename);
  filename = [name ext];
elseif iscell(filename)
  for kk = 1:length(filename)
    [pathstr name ext] = fileparts(filename{kk});
    filename{kk} = [name ext];
  end
end
