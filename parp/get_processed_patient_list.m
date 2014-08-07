function [patient_ids, patient_dirs] = get_processed_patient_list(str_pre_or_post_chemo)
% Get a list of patients that have at least slices determined in Matlab
% [patient_ids, patient_dirs] = get_processed_patient_list(str_pre_or_post_chemo)
% 
% patient_dirs are full paths

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

patient_matlab_dir = fullfile(parp_patient_dir, 'matlab', lower(str_pre_or_post_chemo));
d = dir(fullfile(patient_matlab_dir));

b_valid = cellfun(@(x) ~isempty(regexpi(x, '^\d{3}(PRE|POST)$', 'once')), {d.name});
d = d(b_valid);

patient_ids = get_patient_id_from_name({d.name});
patient_dirs = cellfun(@(x) fullfile(patient_matlab_dir, x), {d.name}, 'UniformOutput', false);
