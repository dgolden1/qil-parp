function p = dandropboxroot
% Return path to Dan's dropbox directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id: dandropboxroot.m 41 2012-09-13 22:38:43Z dgolden $

persistent d_root
if ~isempty(d_root)
  p = d_root;
  return;
end

[stat, hostname] = system('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'dantop.local'
    d_root = '/Users/dgolden/Box Documents';
  case 'goldenmac.stanford.edu'
    d_root = '/Users/dgolden/Box Documents';
  case 'quadcoredan.stanford.edu'
    d_root = '/home/dgolden/Box Documents';
  otherwise
    error('Unknown hostname ''%s''', hostname(1:end-1));
    % d_root = uigetdir(pwd, 'Choose directory of Dan''s scripts');
end

if ~exist(d_root, 'dir')
  error('%s is not a valid directory', d_root);
end

p = d_root;
