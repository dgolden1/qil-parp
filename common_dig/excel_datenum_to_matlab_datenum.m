function matlab_datenum = excel_datenum_to_matlab_datenum(excel_datenum)
% Convert excel date read from xlsread to Matlab datenum
% See http://www.mathworks.com/help/matlab/import_export/when-to-convert-dates-from-excel-files.html

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id: excel_datenum_to_matlab_datenum.m 214 2013-03-07 00:46:28Z dgolden $

if ismac
  matlab_datenum = excel_datenum + datenum('01-Jan-1904');
elseif ispc
  matlab_datenum = excel_datenum + datenum('30-Dec-1899');
else
  error('Excel epoch unknown for %s', computer);
end