function obj = LoadDB(obj, db_filename)
% Load database from a file

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

if ~exist('db_filename', 'var') || isempty(db_filename)
  db_filename = obj.GetDefaultDBFilename;
end

load(db_filename, 'obj');
fprintf('Loaded %s\n', db_filename);
