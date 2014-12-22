function p = qilcasestudyroot
% Return path to Dan's QIL case study directory on different machines

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: qilcasestudyroot.m 2 2012-08-02 23:59:40Z dgolden $

persistent d_root
if ~isempty(d_root)
	p = d_root;
	return;
end

d_root = '/Users/dgolden/documents/qil/case_studies';

if ~exist(d_root, 'dir')
  error('%s is not a valid directory', d_root);
end

p = d_root;
