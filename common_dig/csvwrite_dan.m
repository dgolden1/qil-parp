function csvwrite_dan(output_filename, cell_array)
% My own function to write a CSV file from a cell array, which may contain
% both numeric and text data

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id: csvwrite_dan.m 299 2013-06-12 00:32:52Z dgolden $

%% Check input
if ~all(cellfun(@(x) ischar(x) || isscalar(x) && (isnumeric(x) || islogical(x)), cell_array(:)))
  error('cell_array must consist soley of string and/or scalar numeric data');
end

%% Write
fclose all;
fid = fopen(output_filename, 'w');

for jj = 1:size(cell_array, 1)
  for kk = 1:size(cell_array, 2)
    this_cell = cell_array{jj, kk};
    if isnumeric(this_cell) || islogical(this_cell)
      fprintf(fid, '%G', this_cell);
    else
      %fprintf(fid, '%s', strrep(this_cell, ',', '-'));
      fprintf(fid, '"%s"', strrep(this_cell, '"', '""')); % Surround strings with double quotes and change double quotes two double quotes
    end
    
    % Print a comma unless this is the end of a line
    if kk ~= size(cell_array, 2)
      fprintf(fid, ',');
    end
  end
  
  fprintf(fid, '\n');
end

fclose(fid);