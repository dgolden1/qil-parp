function export_params_to_excel(excel_filename)
% Export parameters to excel spreadsheet

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

mat_filename = 'lesion_parameters_expanded.mat';
params = load(mat_filename);

params = rmfield(params, {'birads', 'ans'});

fn = fieldnames(params.avg);
for kk = 1:length(fn)
   params.(['avg_' fn{kk}]) = [params.avg.(fn{kk})]; 
end
params = rmfield(params, 'avg');

fn = fieldnames(params);
b_params = true(size(fn));
for kk = 1:length(fn)
   if ~all(size(params.(fn{kk})) == [1 12])
      b_params(kk) = false; 
   end
end

params = rmfield(params, fn(~b_params));
fn = fn(b_params);

cell_out = fn(:).';
for kk = 1:length(fn)
  if iscell(params.(fn{kk}))
    cell_out(2:13, kk) = params.(fn{kk})(:);
  else
    cell_out(2:13, kk) = num2cell(params.(fn{kk})(:));
  end
end

csvwrite(strrep(mat_filename, '.mat', '.csv'), cell2mat(cell_out(2:end, 2:end)));
xlswrite(strrep(mat_filename, '.mat', '.xls'), cell_out);

1;
