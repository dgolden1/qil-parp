function ld(varargin)
% List files in current directory, directories first
% ld  <-- list files in current directory
% ld(dirname) <-- list files in dirname directory
% 
% Modified from https://superuser.com/questions/109537/unix-ls-how-to-sort-first-directories-then-files-etc/109542#109542

% By Daniel Golden August 2014

if nargin > 0
  dirname = varargin{1};
else
  dirname = './';
end

fprintf('Directories:\n');
system(sprintf('ls -laF "%s" | grep "^d" | grep -v "^total"', dirname));
fprintf('\nFiles:\n');
system(sprintf('ls -laF "%s" | grep -v "^d" | grep -v "^total"', dirname));
