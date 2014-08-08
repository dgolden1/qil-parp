function p = qilsoftwareroot
% Directory of QIL software

% By Daniel Golden (dgolden1 at gmail dot com) May 2014

p = '/Users/dgolden/Documents/qil/qil_software/qil';
if ~exist(p, 'dir')
  current_filename = mfilename('fullpath');
  error('Update %s.m with path to qil software root directory (i.e., root directory of this repository', current_filename);
end
