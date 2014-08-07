function str_title = title_case(str, b_all_words)
% Convert string to title case

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id: title_case.m 222 2013-03-22 22:55:33Z dgolden $

%% Setup
if ~exist('b_all_words', 'var') || isempty(b_all_words)
  b_all_words = true; % Not used for now
end

if iscellstr(str)
  str_title = cell(size(str));
  for kk = 1:length(str)
    str_title{kk} = title_case(str{kk}, b_all_words);
  end
  return;
end

%% Go
% Get indices of first letters of words
first_letters = regexp(str, '\W\w') + 1;
if ~isempty(regexp(str(1), '^\w'))
  first_letters = [1 first_letters];
end

str_title = lower(str);
str_title(first_letters) = upper(str_title(first_letters));

%% Don't capitalize small words
if ~b_all_words
  
end