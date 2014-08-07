function p = danpaperroot
% Return path to Dan's VLF paper directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2008
% $Id: danpaperroot.m 2 2012-08-02 23:59:40Z dgolden $

persistent d_root
if ~isempty(d_root)
  p = d_root;
  return;
end

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'quadcoredan.stanford.edu'
    d_root = '/home/dgolden/vlf/papers/dgolden';
  case 'dantop.local'
    d_root = '/Users/dgolden/Documents/VLF/dgolden_papers';
  case 'goldenmac.stanford.edu'
    d_root = '/Users/dgolden/Documents/vlf/papers/dgolden';
  otherwise
    error('Unknown hostname ''%s''', hostname(1:end-1));
end

p = d_root;
