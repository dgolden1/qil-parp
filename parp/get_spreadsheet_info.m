function [values, spreadsheet_datenum] = get_spreadsheet_info(patient_id_or_name)
% Get information from Google "Lesion Locations" spreadsheet
% [values, spreadsheet_datenum] = get_spreadsheet_info(patient_id_or_name)
% 
% patient_id_or_name can be either a patient's name or numeric patient ID
% If patient_id_or_name is not supplied, all patient data will be returned

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
spreadsheet_filename = fullfile(qilsoftwareroot, 'parp', 'PARP Lesion Locations.xlsx');

if ~exist('patient_id_or_name', 'var') || isempty(patient_id_or_name)
  patient_id = nan;
else
  if ischar(patient_id_or_name) || iscell(patient_id_or_name) && all(cellfun(@ischar, patient_id_or_name))
    patient_id = get_patient_id_from_name(patient_id_or_name);
  elseif all(isnumeric(patient_id_or_name))
    patient_id = patient_id_or_name;
  end
  
  if any(isnan(patient_id))
    error('Invalid patient id');
  end
end

%% Load spreadsheet data
d = dir(spreadsheet_filename);
if isempty(d)
  error('File %s not found', spreadsheet_filename);
end

persistent values_all_old spreadsheet_datenum_old
if isequal(spreadsheet_datenum_old, d.datenum)
  values_all = values_all_old;
  spreadsheet_datenum = spreadsheet_datenum_old;
else
  values_all = get_combined_pre_post_values(spreadsheet_filename);
  spreadsheet_datenum = d.datenum;
  
  values_all_old = values_all;
  spreadsheet_datenum_old = spreadsheet_datenum;
end


%% Return requested values
if isnan(patient_id)
  values = values_all;
else
  for kk = 1:length(patient_id)
    this_idx_return = find(ismember([values_all.study_id], patient_id(kk)));
    if isempty(this_idx_return)
      error('Did not find exact match for patient ID %d in spreadsheet', patient_id(kk));
    end
    idx_return(kk) = this_idx_return;
  end
  
%   idx_return = find(ismember([values_all.study_id], patient_id));
%   if ~(length(idx_return) == length(patient_id) && all(sort(flatten([values_all(idx_return).study_id])) == sort(patient_id(:))))
%     error('Did not find exact match for selected patient ID in spreadsheet');
%   end
  
  [~, idx_sort] = sort(patient_id(:));
  [~, idx_unsort] = sort(idx_sort); % Take the sorted return values, and de-sort them so patient id lines up with given patient id
  values = values_all(idx_return(idx_unsort));
end

function values_combined = get_combined_pre_post_values(spreadsheet_filename)

values_combined = parse_spreadsheet(spreadsheet_filename, 'Lesions-PRE');
values_post = parse_spreadsheet(spreadsheet_filename, 'Lesions-POST');

if ~isequal([values_combined.study_id], [values_post.study_id])
  error('Study IDs in PRE and POST sheets are not the same');
end

post_fields_to_keep = {'x_mm', 'y_mm', 'z_mm', 'slice_location_mm', 'slice_plane', 'mri_pattern_of_response', 'post_mri_location'};
post_fields_to_add_suffix = {'x_mm', 'y_mm', 'z_mm', 'slice_location_mm', 'slice_plane'};

for kk = 1:length(values_combined)
  for jj = 1:length(post_fields_to_keep)
    if ismember(post_fields_to_keep{jj}, post_fields_to_add_suffix)
      field_suffix = '_post';
    else
      field_suffix = '';
    end
    
    % Add this value to the struct and append '_post' to the name
    values_combined(kk).(sprintf('%s%s', post_fields_to_keep{jj}, field_suffix)) = values_post(kk).(post_fields_to_keep{jj});
  end
end

1;

function values_all = parse_spreadsheet(spreadsheet_filename, sheet_name)
%% Function: parse the spreadsheet


%% Load spreadsheet data
warning('off', 'MATLAB:xlsread:ActiveX');
[num, txt, raw] = xlsread(spreadsheet_filename, sheet_name);
warning('on', 'MATLAB:xlsread:ActiveX');

% Sometimes xlsread reads more columns and rows than exist; remove them
raw(:, all(cellfun(@(x) isnumeric(x) && isnan(x), raw))) = [];
raw(all(cellfun(@(x) isnumeric(x) && isnan(x), raw), 2), :) = [];

%% Parse spreadsheet
col_names = raw(1,:);

% Patient ID column
id_idx = strcmp(col_names, 'Study ID');

% Set non-numeric patient IDs to NaN
raw([false ~cellfun(@isnumeric, raw(2:end, id_idx)).'], id_idx) = {nan};

patient_ids = cell2mat(raw(2:end, id_idx));

for kk = 1:length(col_names)
  this_fieldname = sanitize_struct_fieldname(col_names{kk});

	% Determine whether the column has numeric or string values
  b_column_is_str = sum(cellfun(@(x) length(x) == 1 && isnumeric(x) && isfinite(x), raw(:,kk))) < 5;

  for jj = 1:(size(raw, 1)-1)
    if isnan(patient_ids(jj))
      continue;
    end
    
    if b_column_is_str
      % This column's contents is strings
      this_val = raw{jj+1, kk};
      if isnumeric(this_val) && isnan(this_val)
        this_val = '';
      end
      values_all(jj,1).(this_fieldname) = this_val;
    else
      % This column's contents is numbers
      this_val = raw{jj+1, kk};
      if ischar(this_val)
        this_val = nan;
      end
      values_all(jj,1).(this_fieldname) = this_val;
      
      % Fix datenums. Apparently, Excel's epoch is 1899-12-30, which is
      % weird
      if ismember(col_names{kk}, {'Pre MRI Date'})
        values_all(jj,1).(this_fieldname) = values_all(jj,1).(this_fieldname) + datenum([1899 12 30 0 0 0]);
      end
    end
  end
end

% Remove entries with blank study ids (so far, just ID 43-L and 43-R)
values_all(cellfun(@isempty, {values_all.study_id})) = [];
