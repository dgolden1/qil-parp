function [X, X_names, patient_id] = get_clinical_data(columns_to_exclude)
% Load clinical data from spreadsheet
% [X, X_names, patient_id] = get_clinical_data

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

if ~exist('columns_to_exclude', 'var') || ~iscell(columns_to_exclude)
  columns_to_exclude = {};
end

%% Load spreadsheet info
xls_filename = fullfile(qilsoftwareroot, 'parp', 'PARP Lesion Locations.xlsx');
xls_sheetname = 'Lesions-Clinical';

[num, txt, raw] = xlsread(xls_filename, xls_sheetname);


%% Parse
nrows = size(raw, 1);
ncols = size(raw, 2);

patient_id = [];
patient_id_col = strcmp(raw(1,:), 'Study ID');

col_names = raw(1,:);
col_names_sanitized = sanitize_struct_fieldname(col_names);

b_col_is_numeric = false(size(col_names));
for jj = 1:length(col_names_sanitized)
  % Say a given column is numeric if at least 5 of its entries are numeric
  if sum(cellfun(@(x) isnumeric(x) && ~isnan(x), raw(2:end, jj))) > 5 && ...
     ~ismember(col_names_sanitized{jj}, {'her2_by_ihc'})
    b_col_is_numeric(jj) = true;
  end
end

b_exclude_column = ismember(col_names_sanitized, columns_to_exclude);

for kk = 2:nrows
  this_patient_id = raw{kk, patient_id_col};
  if ~isnumeric(this_patient_id)
    continue;
  end
  
  this_patient_idx = length(patient_id) + 1;
  patient_id(this_patient_idx, 1) = this_patient_id;
  
  for jj = 1:ncols
    if b_exclude_column(jj)
      continue;
    end
    
    this_col_name = col_names_sanitized{jj};
    
    this_cell_val = raw{kk, jj};
    
    % Do different things for different columns
    switch lower(this_col_name)
      case 'clinical_tnm_staging'
        [T, N, M] = parse_tnm(this_cell_val);
        values_struct(this_patient_idx).TNM_T = T;
        values_struct(this_patient_idx).TNM_N = N;
        
      otherwise
        if ~b_col_is_numeric(jj) && isnumeric(this_cell_val) && isnan(this_cell_val)
          % Empty cells are set to NaN instead of '' in the raw{} cell;
          % change them to ''
          this_cell_val = '';
        elseif ~b_col_is_numeric(jj) && isnumeric(this_cell_val)
          % Sometimes the ER/PR status columns are not numeric, but they
          % have numbers in them that need to be converted to strings
          this_cell_val = num2str(this_cell_val);
        end
        values_struct(this_patient_idx).(this_col_name) = this_cell_val;
    end
    
  end
end

fn = fieldnames(rmfield(values_struct, 'study_id'));
for kk = 1:length(fn)
  b_is_numeric = b_col_is_numeric(strcmp(col_names_sanitized, fn{kk}));
  
  if b_is_numeric
    X_cell{kk} = [values_struct.(fn{kk})].';
    X_names_cell{kk} = fn{kk};
  else
    [X_cell{kk}, X_names_cell{kk}] = label_to_dummy({values_struct.(fn{kk})}.');
    X_names_cell{kk} = cellfun(@(x) [fn{kk} '_' x], X_names_cell{kk}, 'UniformOutput', false); % Make column name the prefix for each category
  end
end

X = [X_cell{:}];
X_names = [X_names_cell{:}];

function [t, n, m] = parse_tnm(tnm)
% Make sure T, N and M are capitals and everything else is lowercase
tnm = strrep(strrep(strrep(lower(tnm), 't', 'T'), 'n', 'N'), 'm', 'M');

t = regexp(upper(tnm), '^T[^N]+', 'match', 'once');
n = regexp(upper(tnm), 'N[^M]+', 'match', 'once');
m = regexp(upper(tnm), 'M.+', 'match', 'once');
