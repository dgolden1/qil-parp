function varargout = ListDBs
% List all available PARPDBs
% pdb = ListDBs

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% List databases
base_dir = fullfile(qilcasestudyroot, 'parp', 'parp_db');
d = dir(base_dir);
d = d(cellfun(@(x) x(1) ~= '.', {d.name})); % Get rid of . and .. directories

for kk = 1:length(d)
  dir_name = d(kk).name;
  if isempty(regexp(dir_name, '(^pre)|(^post)', 'once'))
    warning('Invalid database directory name: %s', dir_name);
    continue;
  end
  
  if strcmp(dir_name(1:3), 'pre')
    str_pre_or_post = 'pre';
    suffix = dir_name(5:end);
  else
    str_pre_or_post = 'post';
    suffix = dir_name(6:end);
  end
  
  if isempty(suffix)
    db_constructor_list{kk} = sprintf('PARPDB(''%s'')', str_pre_or_post);
  else
    db_constructor_list{kk} = sprintf('PARPDB(''%s'', ''%s'')', str_pre_or_post, suffix);
  end
  fprintf('%d %s: %s\n', kk, dir_name, db_constructor_list{kk});
end

%% Load databases
if nargout >= 1
  for kk = 1:length(d)
    varargout{1}(kk) = eval(db_constructor_list{kk});
  end
end
