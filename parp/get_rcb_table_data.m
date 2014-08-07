function rcb_struct = get_rcb_table_data(patient_id, b_use_new_file)
% Get data from RCB table
% rcb_struct = get_rcb_table_data(patient_id, b_use_new_file)
% 
% Excluded patients from get_excluded_patient_list.m are NOT included in output

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id$

%% Setup
if ~exist('b_use_new_file', 'var') || isempty(b_use_new_file)
  b_use_new_file = true;
end

%% Load spreadsheet data
if b_use_new_file
  xls_filename = fullfile(qilcasestudyroot, 'parp', 'redcap_reports', 'Report_RCBTableData_2012-11-09_1338.xlsx');
else
  xls_filename = fullfile(qilcasestudyroot, 'parp', 'redcap_reports', 'Report_RCBTableData_2012-10-05_1440.xlsx');
end

[num, txt, raw] = xlsread(xls_filename);

idx_row_valid = all(cellfun(@(x) isnumeric(x) && isfinite(x), raw(2:end, :)), 2);
raw = raw([true; idx_row_valid], :);

%% Get excluded patients
patient_ids_excluded = get_excluded_patient_list;

%% Parse spreadsheet data
these_patient_ids_excluded = [];
for kk = 1:size(raw, 1)-1
  this_patient_id = cell2mat(raw(kk+1, 1));
  if ismember(this_patient_id, patient_ids_excluded)
    % Don't include excluded patients
    these_patient_ids_excluded(end+1,1) = this_patient_id;
    continue;
  else
    if ~exist('rcb_struct', 'var')
      this_idx = 1;
    else
      this_idx = length(rcb_struct) + 1;
    end
  end
  
  rcb_struct(this_idx).patient_id = this_patient_id;
  rcb_struct(this_idx).tumor_area_1 = cell2mat(raw(kk+1, 2));
  rcb_struct(this_idx).tumor_area_2 = cell2mat(raw(kk+1, 3));
  rcb_struct(this_idx).cancer_percent = cell2mat(raw(kk+1, 4));
  rcb_struct(this_idx).in_situ_percent = cell2mat(raw(kk+1, 5));
  rcb_struct(this_idx).num_pos_nodes = cell2mat(raw(kk+1, 6));
  rcb_struct(this_idx).d_largest_node_met = cell2mat(raw(kk+1, 7));
  rcb_struct(this_idx).rcb = cell2mat(raw(kk+1, 8));
  
  % Compute RCB
%   d_prim = sqrt(rcb_struct(this_idx).tumor_area_1*rcb_struct(this_idx).tumor_area_2);
%   f_inv = (1 - rcb_struct(this_idx).in_situ_percent/100)*rcb_struct(this_idx).cancer_percent/100;
%   LN = rcb_struct(this_idx).num_pos_nodes;
%   d_met = rcb_struct(this_idx).d_largest_node_met;
%   rcb_struct(this_idx).rcb_computed = 1.4*(f_inv*d_prim)^0.17 + (4*(1 - 0.75^LN)*d_met)^0.17;
  [rcb_struct(this_idx).rcb_computed, rcb_struct(this_idx).d_prim, rcb_struct(this_idx).f_inv, rcb_struct(this_idx).LN, rcb_struct(this_idx).d_met]= ...
    calculate_rcb(rcb_struct(this_idx).tumor_area_1, rcb_struct(this_idx).tumor_area_2, rcb_struct(this_idx).cancer_percent, ...
    rcb_struct(this_idx).in_situ_percent, rcb_struct(this_idx).num_pos_nodes, rcb_struct(this_idx).d_largest_node_met);
end

%% Select only requested patient IDs
if exist('patient_id', 'var') && ~isempty(patient_id)
  idx_valid = ismember([rcb_struct.patient_id], patient_id);
  
  if sum(idx_valid) ~= length(patient_id)
    error('Not all requested patient IDs available in RCB spreadsheet');
  end
  
  rcb_struct = rcb_struct(idx_valid);
end

%% Sort output
[~, sort_idx] = sort([rcb_struct.patient_id]);
rcb_struct = rcb_struct(sort_idx);
