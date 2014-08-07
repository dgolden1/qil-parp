function [excluded_ids, reason_for_exclusion] = get_excluded_patient_list(b_print)
% Get a list of patients who are excluded for one reason or another
% 
% Reasons include:
% o Crappy MRI scan
% o Multiple lesions
% o Taken off study early
% o Non-triple-negative breast cancer

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
if ~exist('b_print', 'var') || isempty(b_print)
  b_print = false;
end

%% Manually excluded
excluded_ids_and_reasons = {{18, '0.5 T'} ...
                            {51, 'Two adjacent lesions with differential response'} ...
                           };

excluded_ids = cellfun(@(x) x{1}, excluded_ids_and_reasons);
reason_for_exclusion = cellfun(@(x) x{2}, excluded_ids_and_reasons, 'uniformoutput', false);

% excluded_ids = [18 ... Scanned on 0.5 T machine
%                 51 ... Two adjacent lesions, one of which responded and one of which didn't
%                ];
         
%% Patients who did not receive 4 or 6 cycles of treatment
si = get_spreadsheet_info;
patient_id = [si.study_id];
num_treatment_cycles = {si.cycles_of_treatment_received};
patient_id_incomplete_cycles = patient_id(strcmp(num_treatment_cycles, 'Other (progressed, taken off study early, etc)'));

% excluded_ids = union(excluded_ids, patient_id_incomplete_cycles);
excluded_ids = [excluded_ids(:); patient_id_incomplete_cycles(:)];
reason_for_exclusion(end+1:end+length(patient_id_incomplete_cycles)) = {'Taken off study early'};

%% Non-triple-negative patients
% excluded_ids = union(excluded_ids, patient_id(~is_triple_negative(patient_id)));
patient_id_non_tnbc = patient_id(~is_triple_negative(patient_id));
excluded_ids = [excluded_ids(:); patient_id_non_tnbc(:)];
reason_for_exclusion(end+1:end+length(patient_id_non_tnbc)) = {'Not TNBC'};

%% Ensure no patient appears twice in the list
[excluded_ids, idx_unique] = unique(excluded_ids);
reason_for_exclusion = reason_for_exclusion(idx_unique);

%% Print
if b_print
  for kk = 1:length(excluded_ids)
    fprintf('%s: %s\n', patient_id_tostr(excluded_ids(kk)), reason_for_exclusion{kk});
  end
end

1;
