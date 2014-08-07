function sanitized_fieldname = sanitize_struct_fieldname(unsanitized_fieldname, b_lowercase)
% Remove illegal characters from a struct field name
% sanitized_fieldname = sanitize_struct_fieldname(unsanitized_fieldname, b_lowercase)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id: sanitize_struct_fieldname.m 183 2013-02-12 00:32:19Z dgolden $

if ~exist('b_lowercase', 'var') || isempty(b_lowercase)
  b_lowercase = true;
end

sanitized_fieldname = unsanitized_fieldname;

sanitized_fieldname = strtrim(sanitized_fieldname);

if b_lowercase
  sanitized_fieldname = lower(sanitized_fieldname);
end

sanitized_fieldname = strrep(sanitized_fieldname, '(', '');
sanitized_fieldname = strrep(sanitized_fieldname, ')', '');
sanitized_fieldname = strrep(sanitized_fieldname, '%', 'percent');
sanitized_fieldname = strrep(sanitized_fieldname, '#', 'num');


% Replace all non alpha-numeric characters with underscore
if isstr(unsanitized_fieldname)
  sanitized_fieldname(regexp(sanitized_fieldname, '[^a-zA-Z0-9]')) = '_';
elseif iscellstr(unsanitized_fieldname)
  for kk = 1:length(sanitized_fieldname)
    sanitized_fieldname{kk}(regexp(sanitized_fieldname{kk}, '[^a-zA-Z0-9]')) = '_';
  end
end