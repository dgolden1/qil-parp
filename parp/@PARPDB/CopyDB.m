function parpdb_new = CopyDB(obj, varargin)
% Copy a database and apply some changes

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('new_suffix', 'temp');
p.addParamValue('b_overwrite', true);
p.parse(varargin{:});

if isempty(p.Results.new_suffix)
  error('new_suffix cannot be blank');
end

%% Get directory name of new PARPDB
all_db_dir = fileparts(obj.Dirname);
new_dir_suffix = p.Results.new_suffix;
if ~strcmp(new_dir_suffix(1), '_')
  new_dir_suffix = ['_' new_dir_suffix];
end

new_db_dir = fullfile(all_db_dir, [obj.PreOrPostChemo new_dir_suffix]);

%% Copy the old database to the new directory

% Check if target directory exists
if exist(new_db_dir, 'dir') && ~p.Results.b_overwrite
  error('Target database directory %s exists', new_db_dir);
elseif exist(new_db_dir, 'dir')
  rmdir(new_db_dir, 's');
  fprintf('Removed existing directory %s\n', new_db_dir);
end

fprintf('Copying %d patients from %s to %s\n', length(GetPatientList(obj)), obj.Dirname, new_db_dir);

try
  mkdir(new_db_dir);
  copyfile(obj.Dirname, new_db_dir);
catch er
  % Get rid of the partially-copied directory
  rmdir(new_db_dir, 's');
  
  rethrow(er);
end

%% Return new database
parpdb_new = PARPDB(obj.PreOrPostChemo, new_dir_suffix);
