function char_newlines = char_array_to_newline(char_array)
% Convert a char array, like that returned by char(t1, t2, t3, ...) to a single line
% string with newlines

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: char_array_to_newline.m 181 2013-02-08 23:58:21Z dgolden $

char_cell = cellstr(char_array);
char_newlines = '';
for kk = 1:length(char_cell)
  if kk > 1
    char_newlines = sprintf('%s\n', char_newlines);
  end
  
  char_newlines = sprintf('%s%s', char_newlines, char_cell{kk});
end