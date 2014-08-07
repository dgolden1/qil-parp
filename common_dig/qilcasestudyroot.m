function p = qilcasestudyroot
% Return path to Dan's QIL case study directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: qilcasestudyroot.m 2 2012-08-02 23:59:40Z dgolden $

persistent d_root
if ~isempty(d_root)
	p = d_root;
	return;
end

[stat, hostname] = unix('hostname');
switch hostname(1:end-1) % Get rid of newline
	case {'dantop.local','goldenmac.stanford.edu','dantop-air.local','dantop-air'}
		d_root = '/Users/dgolden/documents/qil/case_studies';
  otherwise
    error('Unknown hostname ''%s''', hostname(1:end-1));
    % d_root = uigetdir(pwd, 'Choose case study directory');
end

if ~exist(d_root, 'dir')
  error('%s is not a valid directory', d_root);
end

p = d_root;
