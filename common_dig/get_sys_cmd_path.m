function cmd_path = get_sys_cmd_path(cmd)
% Get full path to a system command (e.g., mogrify, ffmpeg, etc.)
% Error if it doesn't exist

% By Daniel Golden (dgolden1 at gmail dot com) August 2014

[status, cmdout] = system(sprintf('which %s', cmd));
cmdout = strtrim(cmdout);

% Confirm path is not empty
assert(~isempty(cmdout), 'System command ''%s'' not found on path', cmd);

% Check for errors in system command
assert(~status, cmdout);

cmd_path = cmdout;

1;
