function SaveDB(obj)
% Save database to a file

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if isempty(obj.DBFilename)
  error('obj.DBFilename is empty');
end

save(obj.DBFilename, 'obj');
fprintf('Saved %s\n', obj.DBFilename);
