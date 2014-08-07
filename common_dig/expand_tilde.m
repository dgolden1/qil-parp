function filename_out = expand_tilde(filename_in)
% If a filename begins with a tilde (indicating a unix home directory), expand it
% Some functions can't deal with the tilde

% By Daniel Golden (dgolden1 at stanford dot edu) April 2013
% $Id: expand_tilde.m 255 2013-04-27 03:41:20Z dgolden $

if length(filename_in) > 1 && strcmp(filename_in(1:2), ['~' filesep])
  % Fix things like ~/temp, but not ~temp
  
  [~, home_dir] = system('echo ~');
  home_dir = home_dir(1:end-1); % Ditch the newline at the end
  filename_out = [home_dir filename_in(2:end)];
else
  filename_out = filename_in;
end
