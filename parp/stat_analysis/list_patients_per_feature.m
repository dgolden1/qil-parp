function list_patients_per_feature
% List the patients that are common to all feature sets, and the ones that
% are unique to specific feature sets

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Get patient ids for each feature type
[~, ~, patient_id_jj] = collect_features(...
  'jj_str', 'all', 'b_man_char_v1', false, 'b_man_char_v2', false, 'b_birads', false, 'b_glcm', false);

[~, ~, patient_id_man_char_v1] = collect_features(...
  'jj_str', 'none', 'b_man_char_v1', true, 'b_man_char_v2', false, 'b_birads', false, 'b_glcm', false);

[~, ~, patient_id_man_char_v2] = collect_features(...
  'jj_str', 'none', 'b_man_char_v1', false, 'b_man_char_v2', true, 'b_birads', false, 'b_glcm', false);

[~, ~, patient_id_birads] = collect_features(...
  'jj_str', 'none', 'b_man_char_v1', false, 'b_man_char_v2', false, 'b_birads', true, 'b_glcm', false);

[~, ~, patient_id_glcm] = collect_features(...
  'jj_str', 'none', 'b_man_char_v1', false, 'b_man_char_v2', false, 'b_birads', false, 'b_glcm', true);

%% Get patient ids that are common to all features
patient_id_common = multi_intersect(patient_id_jj, patient_id_man_char_v1, patient_id_man_char_v2, patient_id_birads, patient_id_glcm);

%% Get patient ids for each feature that are not in the list of common patient ids
names = {'jiajing''s features', 'man_char_v1', 'man_char_v2', 'birads', 'glcm'};
unique_patient_id_list = {setdiff(patient_id_jj, patient_id_common), ...
                          setdiff(patient_id_man_char_v1, patient_id_common), ...
                          setdiff(patient_id_man_char_v2, patient_id_common), ...
                          setdiff(patient_id_birads, patient_id_common), ...
                          setdiff(patient_id_glcm, patient_id_common)};

%% List them
for kk = 1:length(names)
  fprintf('Patients unique to %s: ', names{kk});
  fprintf('%03d ', unique_patient_id_list{kk});
  fprintf('\n');
end
        
1;

function out = multi_intersect(varargin)
%% Function: Intersect with an arbitrary number of inputs
out = varargin{1};
for kk = 1:(nargin - 1)
  out = intersect(out, varargin{kk+1});
end
