function p = danmatlabroot
% Return path to Dan's matlab script directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) Dec 2008
% $Id: danmatlabroot.m 347 2013-07-17 00:05:49Z dgolden $

persistent d_root
if ~isempty(d_root)
  p = d_root;
  return;
end

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
  case 'dantop'
    d_root = 'C:\Users\Daniel\Documents\VLF\vlf_software';
  case 'dantop.local'
    d_root = '/Users/dgolden/Box Documents/software';
  case 'goldenmac.stanford.edu'
    d_root = '/Users/dgolden/Box Documents/software';
  case 'vlf-alexandria'
    d_root = '/array/data_products/dgolden/software';
  case 'quadcoredan.stanford.edu'
    d_root = '/home/dgolden/vlf/vlf_software/dgolden';
  case 'nansen'
    d_root = '/shared/users/dgolden/software/';
  case 'polarbear'
        d_root = '/home/dgolden1/software';
    case 'vlf-robot2'
        d_root = 'C:\Documents and Settings\vlf\vlf_software';
    case {'scott.stanford.edu', 'shackleton.stanford.edu', 'amundsen.stanford.edu'}
        d_root = '/data/user_data/dgolden/software';
   otherwise
    if ~isempty(regexp(hostname, 'corn[0-9][0-9].stanford.edu'))
      d_root = '~/software';
    elseif ~isempty(regexp(hostname, 'cluster[0-9][0-9][0-9]'))
      d_root = '/shared/users/dgolden/software/';
    else
      error('danmatlabroot:UnknownHost', 'Unknown hostname ''%s''', hostname(1:end-1));
    end
    % d_root = uigetdir(pwd, 'Choose directory of Dan''s scripts');
end

if ~exist(d_root, 'dir')
  error('%s is not a valid directory', d_root);
end

p = d_root;
