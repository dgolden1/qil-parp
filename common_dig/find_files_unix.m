function [filelist, elapsed_time] = find_files_unix(search_dir, args_str)
% Run the unix "find" command and return a list of files
% [filelist, elapsed_time] = find_files_unix(search_dir, args_str)
% 
% Example:
% [filelist, elapsed_time] = find_files_unix('~/temp', '-type f');
% fprintf('Found %d files in %s\n', length(filelist), time_elapsed(0, elapsed_time));

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: find_files_unix.m 209 2013-03-05 23:45:20Z dgolden $

if ~isunix && ~ismac
  error('find_files_unix is not supported on non-Unix platforms');
end

t_start = now;

cmd = sprintf('find "%s" %s', search_dir, args_str);
fprintf('%s\n', cmd);

[status, filelist_str] = system(cmd);
if status ~= 0
  error(filelist_str);
end
if isempty(filelist_str)
  filelist = {};
  return;
  % error('find_files_unix:NoFiles', 'No files found');
end

filelist = textscan(filelist_str, '%s', 'delimiter', '\n');
filelist = filelist{1};

elapsed_time = now - t_start;