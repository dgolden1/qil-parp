function [categories, rcb, patient_ids_out] = get_treatment_response(patient_ids)
% Get various categories of treatment response
% [categories, rcb, patient_ids_out] = get_treatment_response(patient_ids)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Get RCB and RCB categories
rcb_struct = get_rcb_table_data;
if ~issorted(patient_ids)
  error('patient_ids must be sorted');
end
if ~issorted([rcb_struct.patient_id])
  error('RCB struct must be sorted');
end
if ~all(ismember(patient_ids, [rcb_struct.patient_id]))
  error('Patient IDs not found in RCB table: %s', make_comma_separated_list(patient_id_tostr(setdiff(patient_ids, [rcb_struct.patient_id]))));
end
rcb = [rcb_struct(ismember([rcb_struct.patient_id], patient_ids)).rcb].';

%% Get rid of patients without RCB or with invalid RCB table data
idx_valid = isfinite(rcb) & ismember(patient_ids, [rcb_struct.patient_id]);
rcb = rcb(idx_valid);
patient_ids_out = patient_ids(idx_valid);

%% Set categories
categories.rcb_pcr = cell(size(rcb));
categories.rcb_pcr(rcb == 0) = {'pCR'};
categories.rcb_pcr(rcb > 0) = {'RCB>0'};

categories.rcb_gt25 = cell(size(rcb));
categories.rcb_gt25(rcb < 2.5) = {'RCB<2.5'};
categories.rcb_gt25(rcb > 2.5) = {'RCB>2.5'};

categories.rcb_2or3 = cell(size(rcb));
categories.rcb_2or3(rcb > 1.36) = {'RCB 2 or 3'};
categories.rcb_2or3(rcb <= 1.36) = {'RCB 0 or 1'};

categories.rcb_3 = cell(size(rcb));
categories.rcb_3(rcb > 3.28) = {'RCB 3'};
categories.rcb_3(rcb <= 3.28) = {'RCB 0, 1, 2'};

%% Get RCB table categories (residual tumor and nodes)
rcb_struct = rcb_struct(ismember([rcb_struct.patient_id], patient_ids_out));

idx_nodes = [rcb_struct.num_pos_nodes] > 0;
categories.nodes = cell(size(rcb));
categories.nodes(idx_nodes) = {'Node Pos'};
categories.nodes(~idx_nodes) = {'Node Neg'};

idx_tumor = [rcb_struct.cancer_percent] > 0 & [rcb_struct.in_situ_percent] ~= 100;
categories.tumor = cell(size(rcb));
categories.tumor(~idx_tumor) = {'No Tumor'};
categories.tumor(idx_tumor) = {'Residual Tumor'};

idx_tumor_and_nodes = idx_nodes & idx_tumor;
categories.tumor_and_nodes = cell(size(rcb));
categories.tumor_and_nodes(idx_tumor_and_nodes) = {'Tumor and Nodes'};
categories.tumor_and_nodes(~idx_tumor_and_nodes) = {'Not BOTH Tumor and Nodes'};
